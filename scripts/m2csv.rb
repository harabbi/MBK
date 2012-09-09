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

system("find /tmp -size  0 -print0 | xargs -0 sudo rm")
["new", "update"].each() { |tp|
  a = Array.new
  Dir.glob("/tmp/*#{tp}*.csv").each() { |f| a.push(f.split("/").last) }
  a.sort.each() { |f| 
    Net::SCP.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |scp|
      begin
        system("sudo cat /home/philz/mbk/scripts/m_products_cols.txt /tmp/#{f} > /tmp/__tmp")
        system("sudo mv /tmp/__tmp /tmp/#{f}")
        mbkloginfo(__FILE__, "uploading file #{f}")
        scp.upload! "/tmp/#{f}", "#{MBK_MAGENTO_DATA_DIR}var/customimportexport/"
        cnt="0"
        IO.readlines("/tmp/#{f}").each() { |ln|
          begin
            next if cnt.next! == "1"
            s = ln.split("\",\"").first
            s.slice!(0)
            mbkloginfo(__FILE__, "downloading #{s}")
            curl.url = "http://a248.e.akamai.net/origin-cdn.volusion.com/ztna9.tft5b/v/vspfiles/photos/#{s}-2.jpg?"
            curl.perform
            file = File.new("/tmp/#{s}.jpg", "wb")
            file << curl.body_str
            file.close
            system("ssh #{MBK_MAGENTO_USER}@#{MBK_MAGENTO_HOST} mkdir -p /ebs/home/pwood/mbksite/media/catalog/product/#{s[0..0].capitalize}/#{s[1..1].capitalize}")
            scp.upload! "/tmp/#{s}.jpg","/ebs/home/pwood/mbksite/media/catalog/product/#{s[0..0].capitalize}/#{s[1..1].capitalize}"
          rescue
            mbklogerr(__FILE__, "unseccessful image download with error: #{$!}")
          end
        }
        system("sudo rm -f /tmp/*.jpg")
        system("sudo rm -f /tmp/#{f}") 
      rescue
        mbklogerr(__FILE__, "unseccessful scp  with error: #{$!}")
      end
    end
    
    Net::SSH.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |ssh|
      begin
        ssh.exec!("cd mbksite; php -f amartinez_customimportexport.php -- -a -b replace -i #{MBK_MAGENTO_DATA_DIR}var/customimportexport/#{f}") if tp == "update"
        ssh.exec!("cd mbksite; php -f amartinez_customimportexport.php -- -a -b append  -i #{MBK_MAGENTO_DATA_DIR}var/customimportexport/#{f}") if tp == "new"
        mbkloginfo(__FILE__,  "php -f amartinez_customimportexport.php -- -a -b replace -i #{MBK_MAGENTO_DATA_DIR}var/customimportexport/#{f}")
        system("ssh #{MBK_MAGENTO_USER}@#{MBK_MAGENTO_HOST} rm -f #{MBK_MAGENTO_DATA_DIR}var/customimportexport/#{f}")
      rescue
        mbklogerr(__FILE__, "unseccessful ssh with error #{$!}")
      end
    end
  }
}



