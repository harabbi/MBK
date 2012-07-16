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

client  = mbk_magento_init(__FILE__)
session = mbk_magento_login(__FILE__,client)

tbls = ["customer","catalog_category_attribute"]
tbls.each() { |tbl|
  mbk_mage_get_list(client, session, tbl).each() { |h|
    mbk_db_create_table(export_db, tbl, h.keys) 
    mbk_db_insert_values(export_db, tbl, h.keys, h.values) 
  }
}

mbk_magento_logout(client, session)




