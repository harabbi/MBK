#!/usr/bin/env ruby
$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require "rubygems"
gem "selenium-client", ">=1.2.16"
require "selenium/client"
require "mbk_params.rb"

begin
  #system("java -jar selenium-server-standalone-2.21.0.jar [-timeout 3600] &")
  @browser = Selenium::Client::Driver.new( :host => "localhost", :port => 4444, :browser => "*firefox", :url => MBK_VOLUSION_URL, :timeout_in_second => 36000)
  
  puts "Browser created..."
  @browser.start_new_browser_session
  @browser.open "admin"
  @browser.type "name=email", MBK_VOLUSION_USER
  @browser.type "name=password", MBK_VOLUSION_PASS
  @browser.click "name=imageField2", :wait_for => :page	
  puts "Logged in..."

  page = 1
  @browser.open "admin/TableViewer.asp?Table=Customers&Page=#{page}"
  passwordFile = File.open("passwords", "w")

  while(@browser.get_value("id=Page") == page.to_s)
    puts "Page #{page}..."
    500.times.each do |row|
      id = @browser.table_cell_text("//table[@id='tableviewer']/tbody.#{row}.0")
      key = @browser.table_cell_text("//table[@id='tableviewer']/tbody.#{row}.1")
      password = @browser.table_cell_text("//table[@id='tableviewer']/tbody.#{row}.3")
      passwordFile.puts "#{id},#{key},#{password}"
    end
    page += 1
    @browser.open "admin/TableViewer.asp?Table=Customers&Page=#{page}"
  end
  
  passwordFile.close() 
  @browser.close_current_browser_session
  puts "Closed the browser..."
end
