$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)
require 'rubygems'
require 'active_record'
require 'csv'
require 'mbk_utils.rb'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => MBK_DB_HOST,
  :database => "mbk_site_export_#{Time.now.strftime("%Y%m%d")}",
  :username => MBK_DB_USER,
  :password => MBK_DB_PASS
)

class Customer < ActiveRecord::Base 
  self.table_name ="Customers"
end

class String
  def titleize
    split(/(\W)/).map(&:capitalize).join
  end
end

def formatted_number(number)
  begin
    digits = number.gsub(/\D/, '').split(//)

    if (digits.length == 11 and digits[0] == '1')
      digits.shift
    end

    if (digits.length == 10)
      '(%s) %s-%s' % [ digits[0,3].join(""), digits[3,3].join(""), digits[6,4].join("") ]
    end
  rescue
    return ""
  end
end

column_headers = ["email",
"_website",
"_store",
"website_id",
"store_id",
"created_in",
"firstname",
"lastname",
"group_id",
"password_hash",
"_address_city",
"_address_company",
"_address_country_id",
"_address_fax",
"_address_firstname",
"_address_lastname",
"_address_middlename",
"_address_postcode",
"_address_prefix",
"_address_region",
"_address_street",
"_address_suffix",
"_address_telephone",
"_address_default_billing_",
"_address_default_shipping_"]

findex = "0"
Customer.all(:group => 'emailaddress', :conditions => ["password IS NOT NULL"]).each_slice(Customer.all.count/500) do |custs|
  begin
  CSV.open("/tmp/customers_#{findex.next!}.csv", "w", {:force_quotes => true}) do |csv|
    csv << column_headers
    custs.each do |cust|
      if cust.country == "United States" and cust.state.try(:size) == 2
        csv << [ cust.emailaddress.try(:downcase),
          "base",
          "default",
          "1",
          "1",
          "Default Store View",
          cust.firstname.try(:titleize),
          cust.lastname.try(:titleize),
          "1",
          cust.password,
          cust.city,
          cust.companyname,
          "US",
          formatted_number(cust.faxnumber.to_s),
          cust.firstname.try(:titleize),
          cust.lastname.try(:titleize),
          nil,
          cust.postalcode,
          nil,
          cust.state,
          cust.billingaddress1,
          cust.billingaddress2,
          formatted_number(cust.phonenumber.to_s),
          "1",
          "1"];
      end
    end
  end
  rescue
    puts $!
  end
end

a = Array.new
Dir.glob("/tmp/customers*.csv").each() { |f| a.push(f.split("/").last) }
a.sort.each() do |f|
  puts "about to upload #{f}"
  Net::SCP.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |scp|
    begin
      #mbkloginfo(__FILE__, "uploading file #{f}")
      scp.upload! "/tmp/#{f}", "#{MBK_MAGENTO_DATA_DIR}var/customimportexport/customers/"
    rescue
      #mbklogerr(__FILE__, "unseccessful scp  with error: #{$!}")
      puts "unseccessful scp  with error: #{$!}"
      system("sudo mkdir -p /tmp/failed_upload")
      system("sudo mv /tmp/#{f} /tmp/failed_upload/#{f}")
    end
  end
  system("sudo rm -rf /tmp/#{f}") 

  Net::SSH.start(MBK_MAGENTO_HOST, MBK_MAGENTO_USER, :password => MBK_MAGENTO_PASS) do |ssh|
    begin
      ssh.exec!("cd mbksite; php -f amartinez_customimportexport.php -- -ci #{MBK_MAGENTO_DATA_DIR}var/customimportexport/customers/#{f} 2>&1 | tee -a customers.log")
      #mbkloginfo(__FILE__,  "php -f amartinez_customimportexport.php -- -ci #{MBK_MAGENTO_DATA_DIR}var/customimportexport/customers/#{f}")
    rescue
      #mbklogerr(__FILE__, "unseccessful ssh with error #{$!}")
      puts "unseccessful ssh with error #{$!}"
    end
  end
end
