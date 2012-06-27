$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'

MAX_CSV_SIZE = 5000000
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

$con.tables.each() do |t|
  mbkloginfo(__FILE__, "checking for update in table...#{t}")
  colhdr = true
  i = "0"
  mbk_db_lock_table(t)
  $con.select_all("select * from #{t} where ready_to_import=true").each() do |r|
    r.remove!([`ready_to_import`,`updated_at`,`created_at`])
    s = ""; 
    s << "#{r.keys.join(",")}\n" if colhdr; colhdr=false
    s << "#{r.values.join(",")}\n"
    $con.execute("update #{t} set `ready_to_import`=false where `#{r.keys.first}`='#{r[0]}'")
    File.open("#{csvpartdir}/#{t}_#{i}.part", "a+") { |f|
       f.write(s); 
       if f.pos > MAX_CSV_SIZE
         i.next!
         colhdr = true
       end
     }
  end
  mbk_db_unlock()
end
