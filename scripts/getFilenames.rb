#!/usr/bin/env ruby
require "rubygems"
gem "selenium-client", ">=1.2.16"
require "selenium/client"

begin
  #system("java -jar selenium-server-standalone-2.21.0.jar [-timeout 3600] &")
	@browser = Selenium::Client::Driver.new \
		:host => "localhost",
		:port => 4444,
		:browser => "*firefox",
		:url => "http://www.modeltrainstuff.com",
		:timeout_in_second => 6000

	puts "Browser created..."
	@browser.start_new_browser_session
	@browser.open "admin"
	@browser.type "name=email", "philz@modeltrainstuff.com"
	@browser.type "name=password", "voodoo55"
	@browser.click "name=imageField2", :wait_for => :page	
	
  IO.readlines("tablesToDownload").each do |table_name|
    puts "Getting #{table_name.strip}..."
	  @browser.open "admin"
	  @browser.click "id=Inventory_ImportExport", :wait_for => :page
	  @browser.click "//div[@id='StandardIE_Panel']/table/tbody/tr[2]/td/span/a/span", :wait_for => :page
    selection = @browser.get_text("css=option[value=\"#{table_name.strip}\"]")
    @browser.select "name=Table", selection
    @browser.click "css=#span_#{table_name.strip} > table > tbody > tr > td > input[name='disregard']"
	  @browser.select "id=FileType", "label=XML - XML Based Format"
	  @browser.click "css=span.a65chrome_btn_small.save > a > span", :wait_for => :page
    @filepath = @browser.get_attribute "//td/a@href"
	  puts "Found this file <#{@filepath.to_s}> for #{table_name.strip}!"
	  File.open("filesToDownload", "a"){|f| f.puts(@filepath.to_s); f.close()}
	end
	
	@browser.close_current_browser_session
	puts "Closed the browser..."
end