$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'rubygems'
require 'mechanize'
require 'mbk_params.rb'
require 'mbk_utils.rb'
require 'syslogger'
require 'pidfile'

pf = PidFile.new
log = Syslogger.new("#{__FILE__}", Syslog::LOG_PID, Syslog::LOG_LOCAL0)
log.level = Logger::INFO

COL_DATA_FNAME = "columnData"

$a = mbk_volusion_login()

mbk_create_dir(MBK_VOLUSION_OUTPUT_DIR)
IO.readlines("tablesToDownload").each do |table_name|
  log.info "Processing #{table_name.strip}..."

	$a.get('https://www.modeltrainstuff.com/admin/db_export.asp')
	form = $a.page.forms.first
  form.field_with(:name => "Table").value = table_name.strip
	form.checkbox_with(:name => "disregard", :value => table_name.strip).check
	form.checkboxes.each do |c|
		c.check if c.value.split(".").first == table_name.strip
	end
	form.field_with(:name => "FileType").value="XML"
	form.submit
	log.info "   Downloading..."
  $a.download($a.page.link_with(:text => "Click here to download your file").uri,
              File.open("#{MBK_VOLUSION_OUTPUT_DIR}/#{table_name.strip}.xml", "w"))
end
