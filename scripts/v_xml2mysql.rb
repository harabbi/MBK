$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'nokogiri'
require 'active_record'
require 'mbk_params.rb'

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

export_table = ARGV[0].to_s

$con.execute("drop database if exists #{export_table}")
$con.execute("create database if not exists #{export_table}")
$con.execute("use #{export_table}")

xmldir = "#{Dir.pwd}/#{MBK_VOLUSION_OUTPUT_DIR}"
puts "Entering #{xmldir}..."
Dir.chdir(xmldir)
Dir.glob("*.xml").each() { |xml_document|
  f = File.open("#{xmldir}/#{xml_document}"); doc = Nokogiri::XML(f); f.close
  puts "Parsing file #{xml_document}..."
  tbl_name = get_table_name_from_xml(doc)
  flds     = get_table_flds_from_xml(doc, tbl_name)

  s = "create table if not exists #{tbl_name}("
  flds.collect() { |x| s << "#{x} text," }
  s.chomp!(",");  s << ");"
  puts "\nCreating table #{tbl_name}...\n#{s}\n\n"
  $con.execute("#{s}")

  s = ""
  doc.xpath("//#{tbl_name}").each { |node|
    s =  "insert into #{tbl_name} values ("
    node.children.collect() { |x|  s << "#{$con.quote(x.text)}," }
    s.chomp!(",");  s << ");"
    begin
     # puts "#{s[0..100]}"
      $con.execute("#{s}")
    rescue
      puts "ERROR inserting row!"
      puts $!
    end
  }
}
