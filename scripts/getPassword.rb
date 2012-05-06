$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'mbk_params.rb'

a = Mechanize.new

puts "Logging in..."
a.get("#{MBK_VOLUSION_URL}/admin") do |page| 
	page.form_with(:name => 'loginform') do |f| 
	       	f.email = MBK_VOLUSION_USER
		f.password = MBK_VOLUSION_PASS
	end.click_button
end

Dir.mkdir(MBK_VOLUSION_OUTPUT_DIR) unless File.exists?(MBK_VOLUSION_OUTPUT_DIR)

passwordFile = File.open("passwords", "w")
passwordFile.close()

page = 1

job_start = Time.now

while(true)
  puts "Page #{page}"
  puts "  Fetching..."
  start = Time.now
  html = a.get("https://www.modeltrainstuff.com/admin/TableViewer.asp?Table=Customers&Page=#{page.to_s}")
  puts "    took #{(Time.now - start).round}secs"
 
  doc = Nokogiri::HTML(html.body)
  break unless (doc.xpath("//input[@id='Page']").first.attribute("value").text == page.to_s)

  start = Time.now
  puts "  Scraping..."
  passwordFile = File.open("passwords", "a")
  500.times.each do |row|
    id  = doc.xpath("//table[@id='tableviewer']/tbody/tr[#{(row + 1).to_s}]/td[1]").text 
    key = doc.xpath("//table[@id='tableviewer']/tbody/tr[#{(row + 1).to_s}]/td[2]").text 
    pwd = doc.xpath("//table[@id='tableviewer']/tbody/tr[#{(row + 1).to_s}]/td[4]").text 
    passwordFile.puts "#{id},#{key},#{pwd}"
  end
  passwordFile.close()
  puts "    took #{(Time.now - start).round}secs"

  page += 1
end

puts "Finished in #{(Time.now - job_start).round(2)/60}mins"

