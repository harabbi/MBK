$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'nokogiri'
require 'mbk_params.rb'
#require 'mbk_mysql.rb'


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


xmldir = "#{Dir.pwd}/#{MBK_VOLUSION_OUTPUT_DIR}"
Dir.chdir(xmldir)
Dir.glob("*.xml").each() { |xml_document|
  f = File.open("#{xmldir}/#{xml_document}"); doc = Nokogiri::XML(f); f.close

  tbl_name = get_table_name_from_xml(doc)
  flds     = get_table_flds_from_xml(doc, tbl_name)

  s = "create table if not exists #{tbl_name}("
  flds.collect() { |x| s << "#{x} varchar(4096)," }
  s << ");"
  #create table
  puts s
  
  s = ""
  doc.xpath("//#{tbl_name}").each { |node|
    s =  "insert into #{tbl_name} values ("
    node.children.collect() { |x|  s << "'#{x.text}', " }
    s << ");"
    #insert into DB
    puts s
  }
}
