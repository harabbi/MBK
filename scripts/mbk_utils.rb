require "rubygems"
require 'nokogiri'
require 'active_record'
require 'mechanize'
require 'syslogger'
require 'pidfile'
require 'mbk_params.rb'


#_______________________________________________________________________________
def mbk_volusion_login()
  $log.info "Starting Mechanize..."
  begin
    $a = Mechanize.new
    $a.get("#{MBK_VOLUSION_URL}/admin") do |page|
  	  page.form_with(:name => 'loginform') do |f|
  	    f.email = MBK_VOLUSION_USER
  		  f.password = MBK_VOLUSION_PASS
  	  end.click_button
	  end
  	$log.info "Logged in, starting task..."
  	return $a
  rescue
    $log.warn $!
    $log.warn "Error connecting to mechanize!"
    return nil
  end
end
#_______________________________________________________________________________
def mbk_create_dir(d)
  FileUtils.makedirs(d) unless File.exists?(d)
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
    $con = ActiveRecord::Base.connection
  rescue
    $log.warn $!
    $log.warn "Error connecting to database!"
  end
end
#_______________________________________________________________________________
def mbk_app_init(appname)
  $pf = PidFile.new
  $log = Syslogger.new("#{appname}", Syslog::LOG_PID, Syslog::LOG_LOCAL0)
  $log.level = Logger::INFO
end
#_______________________________________________________________________________
