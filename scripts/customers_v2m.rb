require 'rubygems'
require 'active_record'
require 'csv'
require 'mbk_utils.rb'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql2",
  :host     => MBK_DB_HOST,
  :database => "mbk_site_export_#{Time.now.strftime("%Y%m%d")}",
  :username => MBK_DB_USER,
  :password => MBK_DB_PASS
)

class Customer < ActiveRecord::Base 
  self.table_name ="Customers"
end

f = File.open("/tmp/customers.csv", "w")

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


f.write("#{column_headers.join(",")}\n")

Customer.all(:conditions => ["password IS NOT NULL"]).each do |cust|
  if cust.country == "United States" and cust.state.try(:size) == 2
    f.write("\"#{cust.emailaddress.try(:downcase)}\",base,default,1,1,\"Default Store View\",\"#{cust.firstname}\",\"#{cust.lastname}\",1,\"#{cust.password}\",\"#{cust.city}\",\"#{cust.companyname}\",US,\"#{cust.faxnumber}\",\"#{cust.firstname}\",\"#{cust.lastname}\",\"\",\"#{cust.postalcode}\",,\"#{cust.state}\",\"#{cust.billingaddress1}\",\"#{cust.billingaddress2}\",\"#{cust.phonenumber}\",1,1\n")
  end
end
f.close
