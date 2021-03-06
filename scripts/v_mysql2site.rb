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
v_import_tbl = "mbk_site_export_#{Time.now.strftime("%Y%m%d")}" if v_import_tbl.length < 1
mbk_db_create_run(v_import_tbl)

csvdir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/import/csv"

mbk_create_dir(csvdir)
Dir.chdir(csvdir)

$con.tables.each() do |t|
  colhdr = true
  i = "1"
  #mbk_db_lock_table(t)
  rs = $con.select_all("select * from #{t} where mbk_ready_to_import=true")
  if rs.size > 0
    mbkloginfo(__FILE__, "Found #{rs.size} update(s) in table...#{t}") 
    rs.each do |r|
      $con.execute("update #{t} set `mbk_ready_to_import`=false where `#{r.keys.first}`='#{r[r.keys.first]}'")
      r.delete("mbk_ready_to_import")
      r.delete("mbk_updated_at")
      r.delete("mbk_created_at")
    
      if t == "Customers"
        r.delete("password") 
        r.delete("customerid") 
      end
      
      if t == "Products_Joined"
        r.delete("ProductURL")
        r.delete("PhotoURL") 
        r.delete("CategoryTree")
        r.delete("numproductssharingstock")
        r.delete("photoseed")
        r.delete("google_size")
        r.delete("google_color")
        r.delete("google_gender")
        r.delete("google_age_group")
        r.delete("google_availability")
        r.delete("google_pattern")
        r.delete("google_material")
        r.delete("google_product_category")
        r.delete("techspecs")
        r.delete("extinfo")
        r.delete("orderfinished_note")
        r.delete("metatag_keywords")
        r.delete("productdescription_abovepricing")
        r.delete("custom_metatags_override")
        r.delete("ean")
        r.delete("estdaystoship")
        r.delete("CategoryIDs")
        r.delete("OptionIDs")
        r.delete("Accessories")
        r.delete("FreeAccessories")
        r.delete("google_unique_identifier_exists")
        r.delete("google_adult_product")
      end

      s = ""; 
      s << "#{r.keys.join(",")}\n" if colhdr; colhdr=false
      c = get_db_columns(v_import_tbl, t)
      r.keys.size.times() do |cnt|
        if c[(r.keys[cnt]).to_s] == "text" or c[(r.keys[cnt]).to_s].split("(").first.strip == "varchar"
          s << "\"#{r[(r.keys[cnt]).to_s].to_s.gsub(/"/,"\"\"")}\","
        else
          s << "#{r[(r.keys[cnt]).to_s]},"
        end
      end
      s.chomp!(",")
      s << "\n"

      File.open("#{csvdir}/#{t}_#{i}.csv", "a+") do |f|
        f.write(s); 
        if f.pos > MAX_CSV_SIZE
          i.next!
          colhdr = true
        end
      end
    end

    i.to_i.times() do |cnt|
      ufname = "#{csvdir}/#{t}_#{(cnt+1).to_s}.csv"
      mbkloginfo(__FILE__, "Uploading #{ufname}...")
      $a.get("https://www.modeltrainstuff.com/admin/db_import.asp")
      form = $a.page.forms.first

      form.field_with(:name => "import_type").value = t
      form.file_uploads.first.file_name = ufname
      form.radiobutton_with(:name => "OVERWRITE", :value => "Y").check

      form.submit
      if $a.page.body.include? "Import Duration"
        mbkloginfo(__FILE__, "done uploading!")
        File.delete(ufname)
      else
        mbklogerr(__FILE__, "#{ufname} failed to upload!")
        FileUtils.mv(ufname, "#{ufname}.failed_#{Time.now.to_i.to_s}")
      end
    end
  end
  #mbk_db_unlock()
end
