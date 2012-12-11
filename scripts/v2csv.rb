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
  cols = get_db_columns(export_db, "Products_Joined").keys.to_a
  5.times() { |i| cols.pop }
  pcols = get_db_columns("mbk_site_export_#{Time.now.strftime("%Y%m%d")}", "Products_Joined").keys.to_a
  5.times() { |i| pcols.pop }
puts cols
puts pcols
  $con.execute("SELECT * FROM #{export_db}.Products_Joined where mbk_import_#{t}=1").each() { |r|  
    rh = Hash.new
    ph = Hash.new
    5.times() { |i| r.pop }
    i=0; r.each() { |rr| rh[cols[i].to_s] = rr; i=i+1 }
    pcode = rh["productcode"].to_s
    $con.execute("SELECT * FROM mbk_site_export_#{Time.now.strftime("%Y%m%d")}.Products_Joined where productcode='#{pcode}'").each() { |p|  
      5.times() { |i| p.pop }
      i=0; p.each() { |pp| ph[pcols[i].to_s] = pp; i=i+1 }
    }
    cols.each() { |c|
      unless  c == "categoryid" or c == "categoryids"
        puts rh[c].to_s unless rh[c].to_s == ph[c].to_s
      end
    }
  }
}
rescue
  puts $!
  mbklogerr(__FILE__, "unseccessful checking for new products #{$!}")  
end
