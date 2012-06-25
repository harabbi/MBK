$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_params.rb'
require 'mbk_utils.rb'

Dir.mkdir(MBK_VOLUSION_OUTPUT_DIR) unless File.exists?(MBK_VOLUSION_OUTPUT_DIR)

passdir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/export"
mbk_create_dir(passdir)

passwordFile = File.open("#{passdir}/passwords.txt", "w")
passwordFile.close()

$a = mbk_volusion_login()

page = 1

while(true)
  puts "Page #{page}"

  doc = Nokogiri::HTML($a.get("https://www.modeltrainstuff.com/admin/TableViewer.asp?Table=Customers&Page=#{page.to_s}").body
  break unless (doc.xpath("//input[@id='Page']").first.attribute("value").text == page.to_s)
  passwordFile = File.open("#{passdir}/passwords.txt", "a")
  500.times.each do |row|
    id  = doc.xpath("//table[@id='tableviewer']/tbody/tr[#{(row + 2).to_s}]/td[1]").text 
    key = doc.xpath("//table[@id='tableviewer']/tbody/tr[#{(row + 2).to_s}]/td[2]").text 
    pwd = doc.xpath("//table[@id='tableviewer']/tbody/tr[#{(row + 2).to_s}]/td[4]").text 
    passwordFile.puts "#{id},#{key},#{pwd}"
  end
  passwordFile.close()
  page += 1
end
