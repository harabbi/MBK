$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'mbk_params.rb'

Dir.mkdir(MBK_VOLUSION_OUTPUT_DIR) unless File.exists?(MBK_VOLUSION_OUTPUT_DIR)
passwordFile = File.open("passwords", "w")
passwordFile.close()

a = Mechanize.new

puts "Logging in..."
a.get("#{MBK_VOLUSION_URL}/admin") do |page| 
	page.form_with(:name => 'loginform') do |f| 
	       	f.email = MBK_VOLUSION_USER
		f.password = MBK_VOLUSION_PASS
	end.click_button
end

page = 1

while(true)
  puts "Page #{page}"
  html = a.get("https://www.modeltrainstuff.com/admin/TableViewer.asp?Table=Customers&Page=#{page.to_s}")
  doc = Nokogiri::HTML(html.body)
  break unless (doc.xpath("//input[@id='Page']").first.attribute("value").text == page.to_s)
  passwordFile = File.open("passwords", "a")
  500.times.each do |row|
    id  = doc.xpath("//table[@id='tableviewer']/tbody/tr[#{(row + 2).to_s}]/td[1]").text 
    key = doc.xpath("//table[@id='tableviewer']/tbody/tr[#{(row + 2).to_s}]/td[2]").text 
    pwd = doc.xpath("//table[@id='tableviewer']/tbody/tr[#{(row + 2).to_s}]/td[4]").text 
    passwordFile.puts "#{id},#{key},#{pwd}"
  end
  passwordFile.close()
  page += 1
end
