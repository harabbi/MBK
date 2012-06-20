$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'

mbk_app_init(__FILE__)
$con = mbk_db_connect()

v_import_tbl = ARGV[0].to_s
v_import_tbl = "mbk_volusion_export_#{Time.now.strftime("%Y%m%d")}" if v_import_tbl.length < 1
$con.execute("use #{v_import_tbl}")

csvdir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/import/csv"
csvpartdir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/import/csv_part"
mbk_create_dir(csvpartdir)
Dir.chdir(csvpartdir)

ActiveRecord::Base.connection.tables.each() do |t|
  $log.info "checking for update in table...#{t}"
  $con.execute("select * from #{t} where ready_to_import=true").each() do |r|
    puts r
  end
end
