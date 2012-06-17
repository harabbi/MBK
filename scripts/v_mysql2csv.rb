$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'nokogiri'
require 'active_record'
require 'mbk_params.rb'
require 'mbk_utils.rb'
require 'syslogger'
require 'pidfile'

#this utility will run as a service and check the database for customers and products
#that need to be imported than write those records to a csv
#_______________________________________________________________________________
mbk_app_init(__FILE__)
$con = mbk_db_connect()

v_import_tbl = ARGV[0].to_s
v_import_tbl = "mbk_volusion_export_#{Time.now.strftime("%Y%m%d")}" if export_table.length < 1
$con.execute("use #{v_import_tbl}")

csvdir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/import/"

mbk_create_dir(csvdir)
Dir.chdir(csvdir)
Dir.glob("*.csv").each() { |csv|
   tbl =  csv.split(".").first
   f = File.open(xml_document, "r")
   f.close
}

