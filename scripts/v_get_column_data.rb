$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mechanize'
require 'mbk_params.rb'
require 'mbk_utils.rb'

mbk_app_init(__FILE__)
$con = mbk_db_connect()

$a = mbk_volusion_login()
$a.get('https://www.modeltrainstuff.com/admin/db_export.asp')

coldir = "#{MBK_DATA_DIR}/volusion/export/sql"
mbk_create_dir(coldir)

columns = $a.page.search('table tbody tr td span table')
columns.each{|c| columns.delete(c) if !c.nil? and (c.text.include? "Check All")}

IO.readlines("tablesToDownload").each do |table_name|
	$log.info "Processing #{table_name.strip!}..."
  cf = File.open("#{coldir}/#{table_name}.sql", "w")
  s = "create table if not exists `#{table_name}` (\n"
	columns.find{|c| c.search('input').first.attribute('id').text == table_name.strip}.text.strip.split(")").each do |x|
		if x.include? "Virtual Columns"
			x.split(": ")[1].gsub!("*","").downcase.split(" ").each do |virtual_column|
				s << "`#{virtual_column}` text,\n"
			end
		else
		  column, type = x.split(" (")
		  next unless column and type

		  column.gsub!(/^ /, "")
		  column.downcase!
		  column.gsub!("* ", "")

		  type.downcase!
		  type.gsub!("* ", "")
		  type.gsub!(" : ", "(").gsub!(/$/, ")") if type.include?(":")
		  type.gsub!("text", "varchar")
		  type.gsub!("memo", "text")
		  type.gsub!("long", "bigint")
		  type.gsub!("currency", "float")
		  type.gsub!("varchar(-1)", "text")

		  s << "`#{column.strip}` #{type.strip},\n"
		end
	end
	s <<" `ready_to_import` BOOLEAN DEFAULT FALSE, `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `created_at` DATETIME DEFAULT NULL);"
  cf.write s
	cf.close
end
$log.info "Finished collecting column data"