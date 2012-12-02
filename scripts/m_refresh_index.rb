$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'


at_exit do
  if $!.nil? || $!.is_a?(SystemExit) && $!.success?
    mbkloginfo(__FILE__, 'successfully finished')
  else
    code = $!.is_a?(SystemExit) ? $!.status : 1
    mbklogerr(__FILE__, "unseccessful failure with code #{code}")
  end
end

mbk_app_init(__FILE__)

Net::SSH.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |ssh|
  begin
    ssh.exec!("cd mbksite; php -f amartinez_customimportexport.php -- -a 2>&1 | tee -a reindex.log")
    mbkloginfo(__FILE__,  "php -f amartinez_customimportexport.php -- -a ")
  rescue
    mbklogerr(__FILE__, "unseccessful reindex with error #{$!}")
  end
end



