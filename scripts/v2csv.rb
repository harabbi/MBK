$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'
require 'set'

ROW_COUNT = 1000

class String
  def numeric?
    Float(self) != nil rescue false
  end
end

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

export_db = "magento"
begin
cnt ="1"
findex = "1"
["new", "update"].each() { |t|
  cols = get_db_columns(export_db, "m_products").keys.to_a
  5.times() { |i| cols.pop }
  f = File.open("/tmp/products_#{t}_#{Time.now.to_i}_#{findex}.csv",'w')
  f.write("#{cols.join(",")}\n")
  $con.execute("SELECT * FROM #{export_db}.m_products where mbk_import_#{t}=1").each() { |r|
    rf = Array.new
    o = ""
    r.each() { |rr| rf.push(rr) }
    5.times() { |i| rf.pop }
    4.times() { |i| rf.pop } if rf.last.blank?
   
    rf.each() { |rr| 
      if rr.blank?
        o << ","
      else
        rr.gsub!(/\"/,"'")
        rr.gsub!(/\n/, "\\n") 
        if rr.numeric?
          o << "#{rr},"
        else
          o << "\"#{rr}\","
        end
      end
    }
    f.write("#{o.chomp(",")}\n")
    
    cnt.next!
    if cnt.to_i > ROW_COUNT
      cnt ="1"
      findex.next! 
      f.close
      f = File.open("/tmp/products_#{t}_#{Time.now.to_i}_#{findex}.csv",'w')
      f.write("#{cols.join(",")}\n")
    end
  }
  f.close 
  $con.execute("delete FROM #{export_db}.m_products where mbk_import_#{t}=1")
}
rescue
  puts $!
  mbklogerr(__FILE__, "unseccessful checking for new products #{$!}")  
end
