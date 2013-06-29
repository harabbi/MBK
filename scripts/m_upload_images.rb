$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'rubygems'
require 'active_record'
require 'csv'
require 'mbk_utils.rb'
require 'curb'
require 'RMagick'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => MBK_DB_HOST,
  :database => "vm_merged",
  :username => MBK_DB_USER,
  :password => MBK_DB_PASS
)

class Product < ActiveRecord::Base
  self.table_name ="vm_merged.vm_merged_products"
end

curl = Curl::Easy.new
curl2 = Curl::Easy.new

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
Product.where("v_productcode > ?",ARGV[0].to_s).pluck('v_productcode').each() { |s|
#mbk_get_all_product_codes.each() { |s| 
  s = s.upcase
  begin
  Net::SCP.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |scp|
    begin
#      mbkloginfo(__FILE__, "downloading image for #{s}")     
      begin
        curl.url  = "http://a248.e.akamai.net/origin-cdn.volusion.com/ztna9.tft5b/v/vspfiles/photos/#{s}-2.gif"
        curl.perform          
        curl2.url = "http://a248.e.akamai.net/origin-cdn.volusion.com/ztna9.tft5b/v/vspfiles/photos/#{s}-2.jpg"
        curl2.perform          
        #convert gif to jpg
      rescue
      end

      if curl.body_str.size <= 1674 and curl2.body_str.size <= 1674
        system("cp ~/mbk/scripts/noimg.png /tmp/#{s}.jpg")
      else
        if curl.body_str.size > curl2.body_str.size 
          file = File.new("/tmp/#{s}.gif", "wb")
          file << curl.body_str
          file.close
          img =  Magick::Image.read('/tmp/#{s}.gif').first
          img.write("/tmp/#{s}.jpg")
        else
          file = File.new("/tmp/#{s}.jpg", "wb")
          file << curl2.body_str
          file.close
        end
      end

if curl.body_str.size <= 1674 and curl2.body_str.size <= 1674
  puts "cantfind image #{s}" 
else
  puts "uploading image #{s}.jpg (#{(curl.body_str.size > curl2.body_str.size) ? curl.body_str.size : curl2.body_str.size})"
end
      system("ssh #{MBK_MAGENTO_USER}@#{MBK_MAGENTO_HOST} mkdir -p /ebs/home/pwood/mbksite/media/catalog/product/#{s.upcase[0]}/#{s.upcase[1]}")
      scp.upload! "/tmp/#{s}.jpg","/ebs/home/pwood/mbksite/media/catalog/product/#{s.upcase[0]}/#{s.upcase[1]}/"
      system("rm -rf /tmp/#{s}.jpg")
    rescue
      mbklogerr(__FILE__, "unseccessful image download with error: #{$!}")
    end
  end
  rescue
    mbklogerr(__FILE__, "unseccessful connection to server could not upload image #{s}")
  end
}
