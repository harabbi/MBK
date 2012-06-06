require "rubygems"
gem "selenium-client", ">=1.2.16"
require "selenium/client"
require 'nokogiri'
require 'active_record'
require 'mbk_params.rb'
require 'mechanize'

#_______________________________________________________________________________
def mbk_start_selenium()
  begin
    @browser = Selenium::Client::Driver.new \
      :host              => "localhost",
      :port              => 4444,
      :browser           => "*firefox",
      :url               => MBK_VOLUSION_URL,
      :timeout_in_second => 36000
   rescue
     @browser = nil
   end
end
#_______________________________________________________________________________
def mbk_volusion_login_with_selenium(browser)
  begin
    browser.start_new_browser_session
    puts "Browser Created!"
    browser.open  "admin"
    browser.type  "name=email",       MBK_VOLUSION_USER
    browser.type  "name=password",    MBK_VOLUSION_PASS
    browser.click "name=imageField2", :wait_for => :page
    puts "Successfully Logged In!"
  rescue
    puts $!
    put "Error logging in to Site!"
  end
end
#_______________________________________________________________________________
def mbk_create_dir(d)
  Dir.mkdir(d) unless File.exists?(d)
end
#_______________________________________________________________________________
def mbk_db_connect()
  begin
    ActiveRecord::Base.establish_connection(
      :adapter  => "mysql2",
      :host     => MBK_DB_HOST,
      :username => MBK_DB_USER,
      :password => MBK_DB_PASS,
      :database => "mysql"
    )
  rescue
    puts $!
    puts "Error connecting to database!"
  end
end
#_______________________________________________________________________________
