$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'

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

v_import_tbl = ARGV[0].to_s
v_import_tbl = "mbk_volusion_export_#{Time.now.strftime("%Y%m%d")}" if v_import_tbl.length < 1
$con.execute("use #{v_import_tbl}")

csvdir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/import/csv"
csvpartdir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/import/csv_part"

mbk_create_dir(csvpartdir)
Dir.chdir(csvpartdir)

ActiveRecord::Base.connection.tables.each() do |t|
  mbkloginfo(__FILE__, "checking for update in table...#{t}")
  $con.execute("select * from #{t} where ready_to_import=true").each() do |r|
    puts r
    $con.execute("update #{t} set read_to_import=false where ready_to_import=r[0]")

  end
  
  
end
