$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'rubygems'
require 'mechanize'
require 'mbk_params.rb'

a = Mechanize.new

a.get("#{MBK_VOLUSION_URL}/admin") do |page| 
	page.form_with(:name => 'loginform') do |f| 
	       	f.email = MBK_VOLUSION_USER
		f.password = MBK_VOLUSION_PASS
	end.click_button
end

Dir.mkdir(MBK_VOLUSION_OUTPUT_DIR) unless File.exists?(MBK_VOLUSION_OUTPUT_DIR)
IO.readlines("filesToDownload").each do |filename|
	puts "Downloading...#{filename}"
	a.download(filename.strip, File.open( 
		"#{MBK_VOLUSION_OUTPUT_DIR}/" + filename.match(/=(.*?)_/)[1] + ".xml", "w"))
end
