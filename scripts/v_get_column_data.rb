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

mbk_app_init(__FILE__)

$a = mbk_volusion_login(__FILE__)

coldir = "#{Dir.pwd}/#{MBK_DATA_DIR}/volusion/export/sql"
mbk_create_dir(coldir)

$a.get('https://www.modeltrainstuff.com/admin/db_export.asp')

columns = $a.page.search('table tbody tr td span table')
columns.each{|c| columns.delete(c) if !c.nil? and (c.text.include? "Check All")}

IO.readlines("#{Dir.pwd}/tablesToDownload").each do |table_name|
	mbkloginfo(__FILE__, "Processing #{table_name.strip!}...")
  cf = File.open("#{coldir}/#{table_name}.sql", "w")
  s = "create table if not exists `#{table_name}` (\n"
  cnt = "1"
	columns.find{|c| c.search('input').first.attribute('id').text == table_name.strip}.text.strip.split(")").each do |x|
		if x.include? "Virtual Columns"
			x.split(": ")[1].downcase!.split(" ").each do |virtual_column|
        virtual_column.gsub!("*", "")
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

      if column.strip[-2..-1] == "id" and cnt == "1" and type.strip != "text"
		    s << "`#{column.strip}` #{type.strip} PRIMARY KEY,\n" if column.strip[-2..-1] == "id" and cnt == "1"
      else
        s << "`#{column.strip}` #{type.strip},\n"
      end
      cnt.next!
		end
	end
	s <<" `ready_to_import` BOOLEAN DEFAULT FALSE, `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `created_at` DATETIME DEFAULT NULL) ENGINE=MyISAM;"
  cf.write s
	cf.close
end