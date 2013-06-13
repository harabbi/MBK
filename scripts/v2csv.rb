$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'
require 'set'

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

export_db = "volusion"
begin
cnt ="1"
["new", "update"].each() { |t|
  unless $con.execute("SELECT COUNT(*) FROM #{export_db} WHERE mbk_import_#{t}=1").first.fisrt.to_i == 0
  cols  = get_db_columns(export_db, "Products_Joined").keys.to_a;                                        5.times() { |i| cols.pop }
  pcols = get_db_columns("mbk_site_export_#{Time.now.strftime("%Y%m%d")}", "Products_Joined").keys.to_a; 5.times() { |i| pcols.pop }
  
  coltype = get_db_columns("mbk_site_export_#{Time.now.strftime("%Y%m%d")}", "Products_Joined")
  $con.execute("SELECT * FROM #{export_db}.Products_Joined where mbk_import_#{t}=1").each() { |r|  
    rh = Hash.new
    ph = Hash.new
    5.times() { |i| r.pop }
    i=0; r.each() { |rr|  
      rh[cols[i].to_s] = rr.to_s.gsub(/"/, "\"\"")
      i=i+1 
    }
    pcode = rh["productcode"].to_s
#puts "rh--------- #{rh["productname"]}"
    $con.execute("SELECT * FROM mbk_site_export_#{Time.now.strftime("%Y%m%d")}.Products_Joined where productcode='#{pcode}'").each() { |p| 
      5.times() { |i| p.pop }
      i=0; p.each() { |pp| ph[pcols[i].to_s] = pp; i=i+1 }
    }
#puts "ph--------- #{ph["productname"]}"
    if ph.size == 0 and t == "new"
      mbklogdebug(__FILE__,"found a new product => #{rh["productcode"]}")
      insert_statement = "INSERT INTO mbk_site_export_#{Time.now.strftime("%Y%m%d")}.Products_Joined ("
      insert_statement << cols.keys.join(",")
      insert_statement << ") VALUES ("
      cols.each() { |c|
        if coltype[c] == "text" or coltype[c].split("(").first.strip == "varchar" or coltype[c] == "datetime"
          insert_statement << "'#{rh[c]}',"
        else
          insert_statement << "#{rh[c]},"
        end
      }
      insert_statement.chomp!(",")
      insert_statement << ");"
      begin
        puts insert_statement
        $con.execute(insert_statement)
      rescue
        mbklogerr(__FILE__, "ERROR INSERTING NEW PRODUCT INTO PRODUCTS_JOINED #{$!}")
      end
    else
      # CHANGEME AFTER PH3 COMPLETE DELETE THE FOLLOWING LINE
      cols.each() { |c|
        unless rh[c].blank? or ["categoryids","categoryid","stockstatus"].include?(c)
          unless rh[c].to_s == ph[c].to_s
            mbklogdebug(__FILE__, "#{rh["productcode"]} -- column #{c} is different: old=#{ph[c]} new=#{rh[c]}")
            begin
              if coltype[c] == "text" or coltype[c].split("(").first.strip == "varchar" or coltype[c] == "datetime"
                rh[c] = rh[c].to_s.gsub("\\","")
                $con.execute("update mbk_site_export_#{Time.now.strftime("%Y%m%d")}.Products_Joined set #{c}='#{rh[c]}',   mbk_ready_to_import=1 where productcode='#{rh["productcode"]}'") unless ph[c].to_s == rh[c].to_s
              else
                ph[c] = ph[c].to_f.round(2).to_s if coltype[c] == "double" or coltype[c] == "float"
                rh[c] = rh[c].to_f.round(2).to_s if coltype[c] == "double" or coltype[c] == "float"
                $con.execute("update mbk_site_export_#{Time.now.strftime("%Y%m%d")}.Products_Joined set #{c}=#{rh[c]},  mbk_ready_to_import=1 where productcode='#{rh["productcode"]}'") unless ph[c].to_s == rh[c].to_s
              end
            rescue
              mbklogerr(__FILE__, "#{$!}")
            end
          end
        end
      }
    end
    $con.execute("delete from #{export_db}.Products_Joined where productcode='#{rh["productcode"]}'")
  }
  end
}
rescue
  mbklogerr(__FILE__, "unseccessful checking for new products #{$!}")  
end
