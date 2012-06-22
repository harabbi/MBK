$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'

#_______________________________________________________________________________
at_exit do
  if $!.nil? || $!.is_a?(SystemExit) && $!.success?
    $log.info 'successfully finished'
  else
    code = $!.is_a?(SystemExit) ? $!.status : 1
    $log.info "unseccessful failure with code #{code}"
  end
end
#_______________________________________________________________________________

mbk_app_init(__FILE__)

$a = mbk_volusion_login()

csvdir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/import/csv"
mbk_create_dir(csvdir)
Dir.chdir(csvdir)

Dir.glob("*.csv").each() do |csv_document|
  $log.info "Uploading #{csv_document}..."
  $a.get("https://www.modeltrainstuff.com/admin/db_import.asp")
  form = $a.page.forms.first

  form.field_with(:name => "import_type").value = csv_document.gsub(".csv", "").gsub(/_[0-9]*$/, "")
  form.file_uploads.first.file_name = csv_document
  form.radiobutton_with(:name => "OVERWRITE", :value => "Y").check
  form.radiobutton_with(:name => "TEST", :value => "").check

  form.submit
  $log.info "   done!"
end


