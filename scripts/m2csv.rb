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
  unless $con.execute("SELECT COUNT(*) FROM #{export_db}.m_products where mbk_import_#{t}=1").first.first.to_i == 0
  cols = get_db_columns(export_db, "m_products").keys.to_a
  5.times() { |i| cols.pop }
  attr_cols = Array.new
  $con.execute("select distinct a.mbk_attribute_name as colname from #{export_db}.m_products as m inner join vm_merged.product_attributes as a on m.sku=a.v_productcode  where m.mbk_import_#{t}=1").each() { |r| attr_cols.push(r[0].to_s) }
  cols << attr_cols unless attr_cols.empty?
  f = File.open("/tmp/products_#{t}_#{Time.now.to_i}_#{findex}.csv",'w')
  f.write("#{cols.join(",")}\n")
  
  $con.execute("SELECT * FROM #{export_db}.m_products where mbk_import_#{t}=1").each() { |r|
    attrs = Hash.new
    $con2.execute("select mbk_attribute_name, mbk_attribute_value from vm_merged.product_attributes where v_productcode='#{r[0].to_s}' and mbk_attribute_name in ('#{attr_cols.join("','")}')").each() { |kv| attrs[kv[0].to_s] = kv[1].to_s }    

    rf = Array.new
    o = ""
    r.each() { |rr| rf.push(rr) }
    5.times() { |i| rf.pop }
    4.times() { |i| rf.pop } if rf.last.blank?

    rf.each() { |rr| 
#puts rr
      if rr.blank?
        o << ","
      else
        rr.gsub!(/"/,"\"\"")
        rr.gsub!(/\n/, "\\n") 
        if rr.numeric?
          o << "#{rr},"
        else
          o << "\"#{rr}\","
        end
      end
    }
    
    attr_cols.each() { |c|
      unless attrs[c].nil?
        o << "\"#{attrs[c]}\"," 
      else
        o << ","
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
  end
}
rescue
  puts $!
  mbklogerr(__FILE__, "unseccessful checking for new products #{$!}")  
end
