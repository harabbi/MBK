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

mbk_app_init(__FILE__)
$a = mbk_volusion_login(__FILE__)

v_import_tbl = ARGV[0].to_s
v_import_tbl = "mbk_volusion_export_#{Time.now.strftime("%Y%m%d")}" if v_import_tbl.length < 1
$con.execute("use #{v_import_tbl}")

csvdir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/import/csv"

mbk_create_dir(csvdir)
Dir.chdir(csvdir)

$con.tables.each() do |t|
  colhdr = true
  i = "1"
  #mbk_db_lock_table(t)
  rs = $con.select_all("select * from #{t} where ready_to_import=true")
  if rs.size > 0
    mbkloginfo(__FILE__, "Found #{rs.size} update(s) in table...#{t}") 
    rs.each do |r|
      $con.execute("update #{t} set `ready_to_import`=false where `#{r.keys.first}`='#{r[r.keys.first]}'")
      r.delete("ready_to_import")
      r.delete("updated_at")
      r.delete("created_at")
    
      if t == "Customers"
        r.delete("password") 
        r.delete("customerid") 
      end
    
      if t == "Products_Joined"
        r.delete("producturl")
        r.delete("photourl") 
        r.delete("categorytree")
        r.delete("numproductssharingstock")
        r.delete("photoseed")
      end
    
      s = ""; 
      s << "#{r.keys.join(",")}\n" if colhdr; colhdr=false
      c = get_db_columns(v_import_tbl, t)
      r.keys.size.times() do |cnt|
        if c[(r.keys[cnt]).to_s] == "text" or c[(r.keys[cnt]).to_s].split("(").first.strip == "varchar"
          s << "\"#{r[(r.keys[cnt]).to_s]}\","
        else
          s << "#{r[(r.keys[cnt]).to_s]},"
        end
      end
      s.chomp!(",")
      s << "\n"

      File.open("#{csvdir}/#{t}_#{i}.csv", "a+") { |f|
         f.write(s); 
         if f.pos > MAX_CSV_SIZE
           i.next!
           colhdr = true
         end
       }
    end
    i.to_i.times() { |cnt|
      ufname = "#{csvdir}/#{t}_#{(cnt+1).to_s}.csv"
      mbkloginfo(__FILE__, "Uploading #{ufname}...")
      $a.get("https://www.modeltrainstuff.com/admin/db_import.asp")
      form = $a.page.forms.first

      import_table = t
      import_table = "Products" if t == "Products_Joined"
      form.field_with(:name => "import_type").value = import_table
      form.file_uploads.first.file_name = ufname
      form.radiobutton_with(:name => "OVERWRITE", :value => "Y").check
      form.radiobutton_with(:name => "TEST", :value => "").check

      form.submit
      mbkloginfo(__FILE__, "done uploading!")
      File.delete(ufname)
    }
  end
  #mbk_db_unlock()
end
