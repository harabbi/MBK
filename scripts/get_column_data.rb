$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'rubygems'
require 'mechanize'
require 'mbk_params.rb'

puts "Starting Mechanize..."

a = Mechanize.new

a.get("#{MBK_VOLUSION_URL}/admin") do |page| 
	page.form_with(:name => 'loginform') do |f| 
	       	f.email = MBK_VOLUSION_USER
		f.password = MBK_VOLUSION_PASS
	end.click_button
end

puts "Logged in, starting task..."

a.get('https://www.modeltrainstuff.com/admin/db_export.asp')

Dir.mkdir(MBK_VOLUSION_OUTPUT_DIR) unless File.exists?(MBK_VOLUSION_OUTPUT_DIR)
columnFile = File.open("columnData", "w")

columns = a.page.search('table tbody tr td span table')
columns.each{|c| columns.delete(c) if !c.nil? and (c.text.include? "Check All")}

IO.readlines("tablesToDownload").each do |table_name|
	puts "Processing #{table_name.strip}..."
	columnFile.puts "#{table_name.strip}"

	columns.find{|c| c.search('input').first.attribute('id').text == table_name.strip}.text.strip.split(")").each do |x|
		column, type = x.split(" (")
		next unless column and type
		column.gsub!(/^ /, "")
		type.downcase!
		type.gsub!("* ", "")
		type.gsub!(" : ", "(").gsub!(/$/, ")") if type.include?(":")
		type.gsub!("text", "varchar")
		type.gsub!("memo", "text")
		type.gsub!("long", "bigint")
		type.gsub!("currency", "float")
		columnFile.puts "#{column.strip},#{type.strip}"
	end
	columnFile.puts ""
end

puts "Finished collecting column data"
