$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'
require 'curb'

curl = Curl::Easy.new

at_exit do
  if $!.nil? || $!.is_a?(SystemExit) && $!.success?
    mbkloginfo(__FILE__, 'successfully finished')
  else
    code = $!.is_a?(SystemExit) ? $!.status : 1
    mbklogerr(__FILE__, "unseccessful failure with code #{code}")
  end
end

mbk_app_init(__FILE__)

#system("sudo find /tmp -size  0 -print0 | xargs -0 sudo rm")
["new", "update"].each() { |tp|
  a = Array.new
  Dir.glob("/tmp/*#{tp}*.csv").each() { |f| a.push(f.split("/").last) }
  a.sort.each() { |f|
    Net::SCP.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |scp|
      begin
        mbkloginfo(__FILE__, "uploading file #{f}")
        scp.upload! "/tmp/#{f}", "#{MBK_MAGENTO_DATA_DIR}var/customimportexport/#{tp}"
      rescue
        mbklogerr(__FILE__, "unseccessful scp  with error: #{$!}")
        system("sudo mkdir -p /tmp/failed_upload")
        system("sudo mv /tmp/#{f} /tmp/failed_upload/#{f}")
      end
    end
    system("sudo rm -rf /tmp/#{f}") 

    Net::SSH.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |ssh|
      begin
        action = ((tp == "update") ? "replace" : "append")
        ssh.exec!("cd mbksite; php -f amartinez_customimportexport.php -- -b #{action} -i #{MBK_MAGENTO_DATA_DIR}var/customimportexport/#{tp}/#{f} 2>&1 | tee -a #{tp}log")
        mbkloginfo(__FILE__,  "php -f amartinez_customimportexport.php -- -a -b replace -i #{MBK_MAGENTO_DATA_DIR}var/customimportexport/#{f}")
        #system("ssh #{MBK_MAGENTO_USER}@#{MBK_MAGENTO_HOST} rm -f #{MBK_MAGENTO_DATA_DIR}var/customimportexport/#{f}")
      rescue
        mbklogerr(__FILE__, "unseccessful ssh with error #{$!}")
      end
    end
  }
}


