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
mbkloginfo(__FILE__, 'loading Products_Joined from vm_merged...')
system("mysql -u#{MBK_DB_USER} -p#{MBK_DB_PASS} #{export_db} < scripts/run_merged2v.sql")
mbkloginfo(__FILE__, 'successfully finished exported vm_merged to volusion...checking for new products')
