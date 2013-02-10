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
mbkloginfo(__FILE__, "uploading images for file vm_merged products")
mbk_get_all_product_codes.each() { |s| 
  Net::SCP.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |scp|
    begin
      mbkloginfo(__FILE__, "downloading image for #{s}")     
      begin
        curl.url = "http://a248.e.akamai.net/origin-cdn.volusion.com/ztna9.tft5b/v/vspfiles/photos/#{s}-2.gif?"
        curl.perform
        #convert gif to jpg
      rescue
        curl.url = "http://a248.e.akamai.net/origin-cdn.volusion.com/ztna9.tft5b/v/vspfiles/photos/#{s}-2.jpg?"
        curl.perform          
      end
           
      file = File.new("/tmp/#{s}.jpg", "wb")
      file << curl.body_str
      file.close
puts "uploading image #{s}"
      system("ssh #{MBK_MAGENTO_USER}@#{MBK_MAGENTO_HOST} mkdir -p /ebs/home/pwood/mbksite/media/catalog/product/#{s.upcase[0]}/#{s.upcase[1]}")
      scp.upload! "/tmp/#{s}.jpg","/ebs/home/pwood/mbksite/media/catalog/product/#{s.upcase[0]}/#{s.upcase[1]}/"
      system("rm -rf /tmp/#{s}.jpg")
    rescue
      mbklogerr(__FILE__, "unseccessful image download with error: #{$!}")
    end
  end
}
