$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'

at_exit do
  if $!.nil? || $!.is_a?(SystemExit) && $!.success?
    mbkloginfo(__FILE__, 'successfully finished')
  else
    code = $!.is_a?(SystemExit) ? $!.status : 1
    mbklogerr(__FILE__, "unseccessful failure with code #{code}")
  end
end

mbk_app_init(__FILE__)

export_db = ARGV[0].to_s
export_db = "mbk_grandriver_export_#{Time.now.strftime("%Y%m%d")}" if export_db.length < 1
mbk_db_create_run(export_db)
["customers", "products"].each() { |tbl|
  Net::SSH.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |ssh|
    begin
      ssh.exec!("cd mbksite; php -f amartinez_customimportexport.php -- -ce") if tbl == "customers"
      ssh.exec!("cd mbksite; php -f amartinez_customimportexport.php -- -e")  if tbl == "products"
    rescue
      puts $!
    end
  end

  Net::SCP.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |scp|
    begin
      scp.download! "#{MBK_MAGENTO_DATA_DIR}var/customimportexport/#{tbl}.csv", "#{MBK_DATA_DIR}/magento/export/#{tbl}.csv"
    rescue
      puts $!
    end
  end

  cols = File.open("#{MBK_DATA_DIR}/magento/export/#{tbl}.csv").readline.split(",")
  cols.collect() { |x| x = x.strip }
  mbk_db_create_table(export_db, tbl, cols) 
  cnt = "0" 
  File.open("#{MBK_DATA_DIR}/magento/export/#{tbl}.csv").each() { |r| 
    next if cnt.next! == "1" 
    vals = r.split(",")
    vals.collect() { |x| x.gsub!(/\"/,"") }
    mbk_db_insert_values(export_db, tbl, cols, vals) 
  }
}

