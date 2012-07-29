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

["customers", "products"].each() { |tbl|
  #step1: build the csv file
  File.open("#{MBK_DATA_DIR}/magento/import/#{tbl}.csv", "w") do |of|
    #TODO
  end

  #step2: move the file to the magento server
  Net::SCP.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |scp|
    begin
      # Do the file we just made or glob the dir to handle files that failed previously?
      scp.upload! "#{MBK_DATA_DIR}/magento/import/#{tbl}.csv", "#{MBK_MAGENTO_DATA_DIR}var/customimportexport/#{tbl}.csv" # is this missing a slash?
      # Delete the file after success, or move it, or leave it be, or delete/move after the ssh finishes with success?
    rescue
      puts $!
    end
  end

  #step3: run the import script
  Net::SSH.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |ssh|
    begin
      ssh.exec!("cd mbksite; php -f amartinez_customimportexport.php -- -ci ") if tbl == "customers"
      ssh.exec!("cd mbksite; php -f amartinez_customimportexport.php -- -i")  if tbl == "products"
    rescue
      puts $!
    end
  end

}

