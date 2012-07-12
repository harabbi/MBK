$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'

#_______________________________________________________________________________
def numeric_column?(cols, col)
  c = cols["#{col}"]
  return true if c == "bigint(20)" or c == "int(11)" or c == "float" or c == "double" 
  return false
end
#_______________________________________________________________________________
def get_table_name_from_xml(doc)
  begin
    tbl_name = doc.xpath("//Export").first.children.first.name
  rescue
    tbl_name = nil
  end
end
#_______________________________________________________________________________
def get_table_flds_from_xml(doc, tbl)
  flds = Array.new
  begin
    doc.xpath("//#{get_table_name_from_xml(doc)}").first.children.each() { |c| flds.push "`#{c.name}`" }
  rescue
  end
  return flds
end
#_______________________________________________________________________________
at_exit do
  if $!.nil? || $!.is_a?(SystemExit) && $!.success?
    mbkloginfo(__FILE__, 'successfully finished')
  else
    code = $!.is_a?(SystemExit) ? $!.status : 1
    mbklogerr(__FILE__, "unseccessful failure with code #{code}")
  end
end
#_______________________________________________________________________________

mbk_app_init(__FILE__)

export_db = ARGV[0].to_s
export_db = "mbk_volusion_export_#{Time.now.strftime("%Y%m%d")}" if export_db.length < 1
mbk_db_create_run(export_db)
$a = mbk_volusion_login(__FILE__)

MBK_XML_HEADER = "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?><Export>"
MBK_XML_FOOTER = "</Export>"
MBK_XML_MAX_FILE_SIZE ||= "20000000"
MBK_XML_PART_DIR ||= "xml_part"

cols = {}
coldir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/export/sql"
xmldir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/export/xml"
outdir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/export"
xmlpartdir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/export/xml_part"
#____________________________________________________________________________
#split xml into parts place them in xmlpartdir
mbk_create_dir(xmldir)
mbk_create_dir(xmlpartdir)

IO.readlines("#{Dir.pwd}/tablesToDownload").each do |table_name|
  table_name.strip!
  xml_document = "#{table_name}.xml"
  
  mbkloginfo(__FILE__, "#{table_name}...")

  begin
  	$a.get('https://www.modeltrainstuff.com/admin/db_export.asp')
  rescue Timeout::Error
    mbkloginfo(__FILE__, "Connection timed out before #{table_name} could start, going to reconnect...")
    $a = mbk_volusion_login(__FILE__)
  	$a.get('https://www.modeltrainstuff.com/admin/db_export.asp')
  end

  try=1
  begin
    form = $a.page.forms.first
    form.field_with(:name => "Table").value = table_name
    form.checkbox_with(:name => "disregard", :value => table_name).check
    form.checkboxes.each do |c|
      c.check if c.value.split(".").first == table_name.strip
    end
    form.field_with(:name => "FileType").value="XML"
    mbkloginfo(__FILE__, "   Compiling... (try #{try})")
    form.submit
  rescue Timeout::Error
    try+=1
    if try < 4
      $a = mbk_volusion_login(__FILE__)
      retry
    end
    mbklogerror(__FILE__, "#{table_name} xml did not finish compiling... #{$!}!")
  end

	mbkloginfo(__FILE__, "   Downloading...")
  begin 
    $a.download($a.page.link_with(:text => "Click here to download your file").uri,
              File.open("#{outdir}/#{xml_document}", "w"))
    FileUtils.mv("#{outdir}/#{xml_document}", "#{xmldir}/#{xml_document}")
    mbkloginfo(__FILE__, "Done with #{table_name}!")
  rescue
    mbklogerr(__FILE__, "#{xml_document} did not download!")
  end
  
  begin
    f = File.open("#{xmldir}/#{xml_document}"); 
    doc = Nokogiri::XML(f); 
    f.close
  rescue
    mbklogerr(__FILE__, "ERROR: could not read xml file  #{xml_document}....#{$!}")
  end
  
  begin
    mbkloginfo(__FILE__, "Creating table #{table_name}...")
    $con.execute(IO.read("#{coldir}/#{table_name}.sql"))
  rescue
    mbklogerr(__FILE__, "ERROR: could create table #{table_name}....#{$!}")
  end
  File.delete("#{coldir}/#{table_name}.sql")
  
  cols = get_db_columns(export_db, table_name)
  
  begin
    f = File.open("#{xmldir}/#{xml_document}", "r")
    (f.size/MBK_XML_MAX_FILE_SIZE.to_i).floor.times() { |fi|
      fout = File.open("#{xmlpartdir}/#{table_name}_#{fi}.part", "w")
      fout.write(MBK_XML_HEADER) if fi > 0
      fout.write(f.read(MBK_XML_MAX_FILE_SIZE.to_i))
      strmatch = "</#{table_name}>"
      str = f.read(strmatch.length)
      #fout.write(str)
      until str.eql?(strmatch) or f.eof?
        fout.write(str.slice!(0))
        str << f.read(1)
      end
      fout.write(strmatch)
      fout.write(MBK_XML_FOOTER)
      fout.close
    }
    if not f.eof?
      fout = File.open("#{xmlpartdir}/#{table_name}_#{((f.size/MBK_XML_MAX_FILE_SIZE.to_i).floor).to_s}.part", "w")
      fout.write(MBK_XML_HEADER) if f.pos > 0
      fout.write(f.read((f.size-f.pos)))
    end
    fout.close
    f.close
    File.delete("#{xmldir}/#{xml_document}")
  rescue
    mbklogerr(__FILE__,"ERROR: could not split xml file #{xml_document}....#{$!}")
  end
end

#____________________________________________________________________________
#read split xml in xmlpartdir and insert into mysql
mbkloginfo(__FILE__, "Entering #{xmlpartdir}...")

Dir.chdir(xmlpartdir)
Dir.glob("*.part").each() { |xml_document|

  f = File.open("#{xmlpartdir}/#{xml_document}"); doc = Nokogiri::XML(f); f.close
  mbkloginfo(__FILE__, "Parsing file #{xml_document}...")
  tbl_name = get_table_name_from_xml(doc)
  ins = "(#{get_table_flds_from_xml(doc, tbl_name).join(",")},`ready_to_import`,`updated_at`,`created_at`)"
  #mbk_db_lock_table(tbl_name)
  doc.xpath("//#{tbl_name}").each { |node|
    s =  "insert ignore into #{tbl_name} #{ins} values ("
    node.children.collect() { |x|  
      if numeric_column?(cols, x.name) and x.text.size > 0
        s << "#{x.text},"
      else
        s << "#{$con.quote($con.quote_string(x.text))}," 
      end
    }
    s << "false, NOW(), NOW());"

    begin
      $con.execute("#{s}")
    rescue
      mbklogerr(__FILE__, "ERROR inserting row!...#{$!}")
    end
  }
  #mbk_db_unlock
  File.delete(xml_document)
}
