$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'rubygems'
require 'mechanize'
require 'mbk_params.rb'
require 'logger'
require 'mbk_utils.rb'

log = Logger.new(STDOUT)

COL_DATA_FNAME = "columnData"

a = Mechanize.new
a.get("#{MBK_VOLUSION_URL}/admin") do |page| 
	page.form_with(:name => 'loginform') do |f| 
	       	f.email = MBK_VOLUSION_USER
		f.password = MBK_VOLUSION_PASS
	end.click_button
end

Dir.mkdir(MBK_VOLUSION_OUTPUT_DIR) unless File.exists?(MBK_VOLUSION_OUTPUT_DIR)

columnFile = File.open(COL_DATA_FNAME, "w")
IO.readlines("tablesToDownload").each do |table_name|
        log.debug "Processing #{table_name.strip}..."

	a.get('https://www.modeltrainstuff.com/admin/db_export.asp')
	a.page.forms.first.field_with(:name => "Table").value = table_name.strip
	a.page.forms.first.checkbox_with(:name => "disregard", :value => table_name.strip).check
	a.page.forms.first.checkboxes.each do |c| 
		c.check if c.value.split(".").first == table_name.strip
	end
	a.page.forms.first.field_with(:name => "FileType").value="XML"
	a.page.forms.first.submit
	log.debug "   Downloading..."
        a.download(a.page.link_with(:text => "Click here to download your file").uri, 
	           File.open("#{MBK_VOLUSION_OUTPUT_DIR}/#{table_name.strip}.#{Time.now.to_i.to_s}.xml", "w"))
end
