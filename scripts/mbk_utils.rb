require "rubygems"
require 'nokogiri'
require 'active_record'
require 'mechanize'
require 'syslogger'
require 'pidfile'
require 'mbk_params.rb'
require 'fileutils'
require 'mail'
require 'net/scp'
require 'net/ssh'
#_______________________________________________________________________________
def mbk_volusion_login(app)
  $log.info "Starting Mechanize..."
  begin
    $a = Mechanize.new
    $a.keep_alive = true
    $a.get("#{MBK_VOLUSION_URL}/admin") do |page|
  	  page.form_with(:name => 'loginform') do |f|
  	    f.email = MBK_VOLUSION_USER
  		  f.password = MBK_VOLUSION_PASS
  	  end.click_button
	  end
  	mbkloginfo(app, "Logged in, starting task...")
  	return $a
  rescue
    mbklogerr(app, "#{$!}")
    return nil
  end
end
#_______________________________________________________________________________
def init_mbk_mysql_logger
  $con = mbk_db_connect() unless $con
  $con.execute("create database if not exists mbk")
  $con.execute("use mbk")
  $con.execute("create table if not exists log (`tm` datetime,`appname` varchar(2048),`username` varchar(255),`pid` int,`logtype` varchar(255), `uuid` bigint, `read` tinyint, `message` text)")  
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
  #puts msg
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
      :encoding => 'utf8',
      :database => "mysql"
    )
    $con = ActiveRecord::Base.connection
  rescue
    mbklogerr(__FILE__, $!)
  end
end
#_______________________________________________________________________________
def mbk_get_all_product_codes()
  a=Array.new
  begin
    $con.execute("select `v_productcode` from `vm_merged`.`vm_merged_products` group by `v_productcode` order by `v_productcode` asc").each() { |x| a.push("#{x[0].to_s}") }
  rescue
    mbklogerr(__FILE__, "ERROR mbk_get_all_product_codes!...#{$!}")   
  end
  return a
end
#_______________________________________________________________________________
def mbk_db_create_run(db)
  init_mbk_mysql_logger
  $con.execute("CREATE TABLE IF NOT EXISTS `mbk`.`runs` (`id` bigint(20) NOT NULL AUTO_INCREMENT,`tm` datetime DEFAULT NULL,`dbname` varchar(255) NOT NULL DEFAULT '',PRIMARY KEY (`id`),UNIQUE KEY `dbname` (`dbname`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")
  begin
    $con.execute("INSERT INTO  `mbk`.`runs` (`tm` ,`dbname`) VALUES (NOW(), '#{db}')")
  rescue
  end
  $con.execute("create database if not exists #{db}")
  $con.execute("use #{db}")
  return db
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
def get_db_columns(db, tbl)
  cols = Hash.new
  $con.execute("SHOW COLUMNS FROM #{db}.#{tbl}").each() { |x|  cols["#{x[0].to_s}"] = x[1].to_s }
  return cols
end
#_______________________________________________________________________________
def mbk_db_create_table(db, tbl, cols)  
  s = "CREATE TABLE IF NOT EXISTS `#{db}`.`#{tbl}` ( "
  cols.each() { |k| s << "`#{k.strip}` text, " }
	s << " `mbk_ready_to_import` BOOLEAN DEFAULT FALSE, `mbk_updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `mbk_created_at` DATETIME DEFAULT NULL) ENGINE=MyISAM;"
  begin
    $con.execute("#{s}")
  rescue
    mbklogerr(__FILE__, "ERROR creating table!...#{$!}")
  end
end
#_______________________________________________________________________________
def mbk_db_insert_values(db, tbl, cols, vals) 
  s = "INSERT INTO `#{db}`.`#{tbl}` ("
  cols.each() { |k| s << "`#{k.strip}`,"  }
  s <<  "`mbk_ready_to_import`,`mbk_updated_at`,`mbk_created_at`) VALUES ("
  vals.push(false)
  vals.push("NOW()")
  vals.push("NOW()")
  vals.each() { |v| s << "?," }
  s[s.length-1] = ")"
  begin
    sql_arr = [s] + vals   
    s = ActiveRecord::Base.send(:sanitize_sql_array,sql_arr)
    res = $con.execute(s)
  rescue
    mbklogerr(__FILE__, "ERROR inserting row!...#{$!}")
  end
end
#_______________________________________________________________________________
def mbk_app_init(appname)
  $log = Syslogger.new("#{appname}", Syslog::LOG_PID, Syslog::LOG_LOCAL0)
  $log.level = Logger::INFO
  $con = mbk_db_connect() 
  init_mbk_mysql_logger
  begin
    $pf = PidFile.new
    $uuid = ($pf.pid.to_s + Time.now.to_i.to_s).to_i
  rescue
    $uuid = 0
    mbklogerr(appname, "ALREADY RUNNING")
  end
  mbkloginfo(appname, "started")
end
#_______________________________________________________________________________
def mbk_send_mail(subject,body)
  begin
    Mail.deliver do
      from "error@mbk.net"
      to "#{MBK_ADMIN_EMAIL}"
      subject "#{subject}"
      body "#{body}"
    end
  rescue
    mbklogerr(__FILE__, "COULD NOT SEND EMAIL: #{$!}")    
  end
end
