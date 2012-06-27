require "rubygems"
require 'nokogiri'
require 'active_record'
require 'mechanize'
require 'syslogger'
require 'pidfile'
require 'mbk_params.rb'
require 'fileutils'

#_______________________________________________________________________________
def mbk_volusion_login(app)
  $log.info "Starting Mechanize..."
  begin
    $a = Mechanize.new
    $a.get("#{MBK_VOLUSION_URL}/admin") do |page|
  	  page.form_with(:name => 'loginform') do |f|
  	    f.email = MBK_VOLUSION_USER
  		  f.password = MBK_VOLUSION_PASS
  	  end.click_button
	  end
  	mbkloginfo(app, "Logged in, starting task...")
  	return $a
  rescue
    mbklogerr(app, $!)
    return nil
  end
end
#_______________________________________________________________________________
def init_mbk_mysql_logger
  $con = mbk_db_connect() unless $con
  $con.execute("create database if not exists mbk")
  $con.execute("use mbk")
  $con.execute("create table if not exists log (`tm` timestamp,`appname` varchar(2048),`username` varchar(255),`pid` int,`logtype` varchar(255), `uuid` bigint, `read` tinyint, `message` text)")  
end
#_______________________________________________________________________________
def mbklogerr(app,msg)
  mbklog(app,msg,"ERROR")
end
#_______________________________________________________________________________
def mbkloginfo(app,msg)
  mbklog(app,msg,"INFO")
end
#_______________________________________________________________________________
def mbklogdebug(app,msg)
  mbklog(app,msg,"DEBUG")
end
#_______________________________________________________________________________
def mbklog(app,msg,type)
  init_mbk_mysql_logger unless $con  
  $con.execute("insert into mbk.log values (NOW(),'#{app}','#{ENV['USER']}',#{Process.pid},'#{type}',#{$uuid},0,#{$con.quote($con.quote_string(msg))})")  
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
    mbklogerr(__FILE__, $!)
  end
end
#_______________________________________________________________________________
def mbk_db_lock_table(tbl)
  $con.execute("LOCK TABLES #{tbl} WRITE")
end
#_______________________________________________________________________________
def mbk_db_unlock()
  $con.execute("UNLOCK TABLES")
end
#_______________________________________________________________________________
def mbk_app_init(appname)
  begin
    $pf = PidFile.new
    $uuid = ((Time.now.to_f*10)%10000000).round(0)
  rescue
    mbklogerr(appname, "ALREADY RUNNING")
  end
  $log = Syslogger.new("#{appname}", Syslog::LOG_PID, Syslog::LOG_LOCAL0)
  $log.level = Logger::INFO
  $con = mbk_db_connect() 
  init_mbk_mysql_logger
  mbkloginfo(appname, "started")
end
#_______________________________________________________________________________
