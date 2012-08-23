$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'
require 'set'

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

export_db = ARGV[0].to_s
export_db = "mbk_site_export_#{Time.now.strftime("%Y%m%d")}" if export_db.length < 1

system("mysql -u#{MBK_DB_USER} -p#{MBK_DB_PASS} #{export_db} < scripts/create_vm_merged_products.sql")
system("mysql -u#{MBK_DB_USER} -p#{MBK_DB_PASS} vm_merged    < scripts/create_vm_merged_products.sql")
mbkloginfo(__FILE__, 'loading vm_merged...')
system("mysql -u#{MBK_DB_USER} -p#{MBK_DB_PASS} #{export_db} < scripts/run_v2merged.sql")

mbkloginfo(__FILE__, 'successfully finished loading vm_merged...checking for new products')
#compare vmmerge for new v_productcode 
r1 = Array.new
r2 = Array.new
begin
  $con.execute("SELECT v_productcode FROM #{export_db}.vm_merged_products").each() { |r| r1.push(r[0].to_s) }
  $con.execute("SELECT v_productcode FROM vm_merged.vm_merged_products").each()    { |r| r2.push(r[0].to_s) }
  r3=(r1-r2)
  r3.each() { |id|
   $con.execute("insert into `vm_merged`.`vm_merged_products` (select * from #{export_db}.vm_merged_products where v_productcode='#{id}')")
   $con.execute("update `vm_merged`.`vm_merged_products` set mbk_import_new=1 where v_productcode='#{id}'")
   #$con.execute("delete from `#{export_db}`.`vm_merged_products` where v_productcode='#{id}'")          
  }
rescue
  mbklogerr(__FILE__, "unseccessful checking for new products #{$!}")  
end

mbkloginfo(__FILE__, 'checking for updated products...')
r4=r1-r3
begin
  r4.each() { |id|
    rs1 = $con.execute("select * from `vm_merged`.`vm_merged_products` where v_productcode='#{id}'")
    rs2 = $con.execute("select * from `#{export_db}`.`vm_merged_products` where v_productcode='#{id}'")
    if rs1.count == 1 and rs2.count == 1 then
      rs1=rs1.to_a
      rs2=rs2.to_a
      #5.times() { |i| rs1.pop; rs2.pop }
      if rs1.to_set != rs2.to_set then 
        $con.execute("delete from `vm_merged`.`vm_merged_products` where v_productcode='#{id}'")       
        $con.execute("insert into `vm_merged`.`vm_merged_products` (select * from #{export_db}.vm_merged_products where v_productcode='#{id}')")
        $con.execute("update `vm_merged`.`vm_merged_products` set mbk_import_update=1 where v_productcode='#{id}'")
        #$con.execute("delete from `#{export_db}`.`vm_merged_products` where v_productcode='#{id}'")          
      end
    end
  }
rescue
  mbklogerr(__FILE__, "unseccessful checking for updated products #{$!}")  
end
