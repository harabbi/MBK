require 'rubygems'
require 'mechanize'

a = Mechanize.new

a.get('http://www.modeltrainstuff.com/admin') do |page| 
	page.form_with(:name => 'loginform') do |f| 
	       	f.email = "philz@modeltrainstuff.com"
		f.password = "voodoo55"
	end.click_button
end

IO.readlines("filesToDownload").each do |filename|
	puts filename
	a.download(filename.strip, File.open( 
		"fetched_xml/" + filename.match(/=(.*?)_/)[1] + ".xml", "w"))
end
