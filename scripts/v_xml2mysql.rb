$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'

#_______________________________________________________________________________
def numeric_column?(cols, col)
  c = cols["#{col}"]
  return true if c == "bigint(20)" or c == "int(11)" or c == "float" or c == "double" 
  return false
end
#_______________________________________________________________________________
def get_db_columns(db, tbl)
  cols = Hash.new
  $con.execute("SHOW COLUMNS FROM #{db}.#{tbl}").each() { |x|  cols["#{x[0].to_s}"] = x[1].to_s }
  return cols
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

export_table = ARGV[0].to_s
export_table = "mbk_volusion_export_#{Time.now.strftime("%Y%m%d")}" if export_table.length < 1

$con.execute("create database if not exists #{export_table}")
$con.execute("use #{export_table}")

MBK_XML_HEADER = "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?><Export>"
MBK_XML_FOOTER = "</Export>"
MBK_XML_MAX_FILE_SIZE ||= "20000000"
MBK_XML_PART_DIR ||= "xml_part"

cols = {}
coldir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/export/sql"
xmldir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/export/xml"
xmlpartdir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/export/xml_part"
#____________________________________________________________________________
#split xml into parts place them in xmlpartdir
mbk_create_dir(xmldir)
mbk_create_dir(xmlpartdir)

Dir.chdir(xmldir)
Dir.glob("*.xml").each() { |xml_document|
  begin
    f = File.open("#{xmldir}/#{xml_document}"); doc = Nokogiri::XML(f); f.close
    tbl_name = get_table_name_from_xml(doc)
    mbkloginfo(__FILE__, "Creating table #{tbl_name}...")
    $con.execute(IO.read("#{coldir}/#{tbl_name}.sql"))
    File.delete("#{coldir}/#{tbl_name}.sql")
  rescue
    mbklogerr(__FILE__, "ERROR: could create table #{tbl_name}....#{$!}")
  end
  cols = get_db_columns(export_table, tbl_name)
  
  begin
    tbl =  xml_document.split(".").first
    f = File.open(xml_document, "r")
    (f.size/MBK_XML_MAX_FILE_SIZE.to_i).floor.times() { |fi|
      fout = File.open("#{xmlpartdir}/#{tbl}_#{fi}.part", "w")
      fout.write(MBK_XML_HEADER) if fi > 0
      fout.write(f.read(MBK_XML_MAX_FILE_SIZE.to_i))
      strmatch = "</#{tbl}>"
      fout.write((str = f.read(strmatch.length)))
      until str.eql?(strmatch) or f.eof?
        fout.write(str.slice!(0))
        str << f.read(1)
      end
      fout.write(strmatch)
      fout.write(MBK_XML_FOOTER)
      fout.close
    }
    fout = File.open("#{xmlpartdir}/#{tbl}_#{((f.size/MBK_XML_MAX_FILE_SIZE.to_i).floor+1).to_s}.part", "w")
    fout.write(MBK_XML_HEADER) if f.pos > 0
    fout.write(f.read((f.size-f.pos)))
    fout.close
    f.close
    File.delete(xml_document)
  rescue
    mbklogerr(__FILE__,"ERROR: could not split xml file #{xml_document}....#{$!}")
  end
}
#____________________________________________________________________________
#read split xml in xmlpartdir and insert into mysql
mbkloginfo(__FILE__, "Entering #{xmlpartdir}...")

Dir.chdir(xmlpartdir)
Dir.glob("*.part").each() { |xml_document|
  f = File.open("#{xmlpartdir}/#{xml_document}"); doc = Nokogiri::XML(f); f.close
  mbkloginfo(__FILE__, "Parsing file #{xml_document}...")
  tbl_name = get_table_name_from_xml(doc)
  ins = "(#{get_table_flds_from_xml(doc, tbl_name).join(",")},`ready_to_import`,`updated_at`,`created_at`)"
  
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
  File.delete(xml_document)
}
