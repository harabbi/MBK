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

IO.readlines("#{Dir.pwd}/tablesToDownload").each do |table_name|
	mbkloginfo(__FILE__, "Processing #{table_name.strip!}...")
  cf = File.open("#{coldir}/#{table_name}.sql", "w")
  s = "create table if not exists `#{table_name}` (\n"
  cnt = "1"

  $a.page.search("#span_#{table_name} label").each do |x|
		unless x.text.include? "Check All"
		  column, type = x.text.split(" (") || x.text

      #TODO Rip this OUT!!!
      next if column == "ProductDescription"

      if type.nil?
        # virtual column
        column.gsub!("*", "")
        n = "`#{column}` text,\n"

      else
        column.downcase!
        column.gsub!(/^ /, "")
        column.gsub!("* ", "")

        type.downcase!
        type.gsub!(/\).*$/, "") # strip the ')' and anything else off the end
        type.gsub!(" : ", "(").gsub!(/$/, ")") if type.include?(":") # a ':' indicates string length, replace the : and wrap the number in '( )'
        type.gsub!("text", "varchar")
        type.gsub!("memo", "text")
        type.gsub!("long", "bigint")
        type.gsub!("currency", "float")
        type.gsub!("varchar(-1)", "text")

        if column.strip[-2..-1] == "id" and cnt == "1" and type.strip != "text"
          n = "`#{column.strip}` #{type.strip} PRIMARY KEY,\n" if column.strip[-2..-1] == "id" and cnt == "1"
        else
          n = "`#{column.strip}` #{type.strip},\n"
        end
      end
      cnt.next!
      s << n
		end
	end
	s <<" `mbk_ready_to_import` BOOLEAN DEFAULT FALSE, `mbk_updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `mbk_created_at` DATETIME DEFAULT NULL) ENGINE=MyISAM;"
  cf.write s
	cf.close
end
