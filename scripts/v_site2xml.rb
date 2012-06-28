$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'

#_______________________________________________________________________________
at_exit do
  if $!.nil? || $!.is_a?(SystemExit) && $!.success?
    mbkloginfo(__FILE__, 'successfully finished')
  else
    code = $!.is_a?(SystemExit) ? $!.status : 1
    mbklogerr(__FILE__, "unseccessful failure with code #{code}")
  end
end
#_______________________________________________________________________________

mbk_create_dir(MBK_VOLUSION_OUTPUT_DIR)
mbk_create_dir("#{MBK_VOLUSION_OUTPUT_DIR}/xml")
mbk_app_init(__FILE__)
$a = mbk_volusion_login(__FILE__)

IO.readlines("#{Dir.pwd}/tablesToDownload").each do |table_name|
  mbkloginfo(__FILE__, "#{table_name.strip}...")

  begin
  	$a.get('https://www.modeltrainstuff.com/admin/db_export.asp')
  rescue Timeout::Error
    mbkloginfo(__FILE__, "Connection timed out before #{table_name.strip} could start, going to reconnect...")
    $a = mbk_volusion_login(__FILE__)
  	$a.get('https://www.modeltrainstuff.com/admin/db_export.asp')
  end

	form = $a.page.forms.first
  form.field_with(:name => "Table").value = table_name.strip
	form.checkbox_with(:name => "disregard", :value => table_name.strip).check
	form.checkboxes.each do |c|
		c.check if c.value.split(".").first == table_name.strip
	end
	form.field_with(:name => "FileType").value="XML"
  mbkloginfo(__FILE__, "   Compiling...")
	form.submit

	mbkloginfo(__FILE__, "   Downloading...")
  begin 
    $a.download($a.page.link_with(:text => "Click here to download your file").uri,
              File.open("#{MBK_VOLUSION_OUTPUT_DIR}/#{table_name.strip}.xml", "w"))
    FileUtils.mv("#{MBK_VOLUSION_OUTPUT_DIR}/#{table_name.strip}.xml", "#{MBK_VOLUSION_OUTPUT_DIR}/xml/#{table_name.strip}.xml")
    mbkloginfo(__FILE__, "Done with #{table_name.strip}!")
  rescue
    mbklogerr(__FILE__, "#{table_name.strip} xml did not download!")
  end
end
