$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'nokogiri'
require 'active_record'
require 'mbk_params.rb'
require 'mbk_utils.rb'
require 'logger'
require 'pidfile'

#this utility assumes the output xml is from volusions custom export utility of the form...
# <xml>
#  <Export>
#    <tablename record1>
#      <table column1>column data1</table column1>
#       ...
#      <table columnn>column dataN</table columnN>
#    </tablename record1>
#     ...
#    <tablename recordN>
#      <table column1>column data1</table column1>
#       ...
#      <table columnn>column dataN</table columnN>
#    </tablename recordN>
#  </Export>
#</xml>
#...it also assumes homogeneous data in each file
#
#
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
    doc.xpath("//#{get_table_name_from_xml(doc)}").first.children.each() { |c| flds.push c.name }
  rescue
  end
  return flds
end
#_______________________________________________________________________________
ActiveRecord::Base.establish_connection(
  :adapter  => "mysql2",
  :host     => MBK_DB_HOST,
  :username => MBK_DB_USER,
  :password => MBK_DB_PASS,
  :database => "mysql"
)
$con = ActiveRecord::Base.connection

if ARGV.size < 1 then
  puts "\n\nUsage: #{__FILE__} <output_database name>"
  exit -1
end
pf = PidFile.new
log = Logger.new(STDOUT)

export_table = ARGV[0].to_s

$con.execute("drop database if exists #{export_table}")
$con.execute("create database if not exists #{export_table}")
$con.execute("use #{export_table}")

MBK_XML_MAX_FILE_SIZE = 20000000
MBK_XML_HEADER = "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?><Export>"
MBK_XML_FOOTER = "</Export>"
MBK_XML_PART_DIR = "xml_part"
xmldir = "#{Dir.pwd}/#{MBK_VOLUSION_OUTPUT_DIR}"
xmlpartdir = "#{xmldir}/#{MBK_XML_PART_DIR}"

Dir.chdir(xmldir)
mbk_create_dir(xmlpartdir)
Dir.glob("*.xml").each() { |xml_document|
   tbl =  xml_document.split(".").first
   f = File.open(xml_document, "r")
   (f.size/MBK_XML_MAX_FILE_SIZE).floor.times() { |fi|
      fout = File.open("#{xmlpartdir}/#{tbl}_#{fi}.part", "w")
      fout.write(MBK_XML_HEADER) if fi > 0
      fout.write(f.read(MBK_XML_MAX_FILE_SIZE))
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
   fout = File.open("#{xmlpartdir}/#{tbl}_#{((f.size/MBK_XML_MAX_FILE_SIZE).floor+1).to_s}.part", "w")
   fout.write(MBK_XML_HEADER) if f.pos > 0
   fout.write(f.read((f.size-f.pos)))
   fout.close
   f.close
}


log.debug "Entering #{xmlpartdir}..."
Dir.chdir(xmlpartdir)
Dir.glob("*.part").each() { |xml_document|
  f = File.open("#{xmlpartdir}/#{xml_document}"); doc = Nokogiri::XML(f); f.close
  log.debug "Parsing file #{xml_document}..."
  tbl_name = get_table_name_from_xml(doc)
  flds     = get_table_flds_from_xml(doc, tbl_name)

  s = "create table if not exists #{tbl_name}("
  flds.collect() { |x| s << "#{x} text," }
  s.chomp!(",");  s << ");"
  log.debug "Creating table #{tbl_name}...#{s}"
  $con.execute("#{s}")

  s = ""
  doc.xpath("//#{tbl_name}").each { |node|
    s =  "insert into #{tbl_name} values ("
    node.children.collect() { |x|  s << "#{$con.quote(x.text)}," }
    s.chomp!(",");  s << ");"
    begin
      $con.execute("#{s}")
    rescue
      puts "ERROR inserting row!"
      puts $!
    end
  }
}
