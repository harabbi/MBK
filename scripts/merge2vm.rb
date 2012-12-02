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

system("mysql -u#{MBK_DB_USER} -p#{MBK_DB_PASS} magento < scripts/create_m_products.sql")
system("mysql -u#{MBK_DB_USER} -p#{MBK_DB_PASS} magento < scripts/create_v_products.sql")
system("mysql -u#{MBK_DB_USER} -p#{MBK_DB_PASS} magento < scripts/run_merged2vm.sql")
