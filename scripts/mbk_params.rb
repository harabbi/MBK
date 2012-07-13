#Add the following env variables to your .bashrc and 
#set them with the appropriate values...or hardcode them in 

MBK_VOLUSION_URL        = ENV["MBK_VOLUSION_URL"]
MBK_VOLUSION_USER       = ENV["MBK_VOLUSION_USER"]
MBK_VOLUSION_PASS       = ENV["MBK_VOLUSION_PASS"]
MBK_VOLUSION_OUTPUT_DIR = ENV["MBK_VOLUSION_OUTPUT_DIR"]
MBK_DATA_DIR            = ENV["MBK_DATA_DIR"]

MBK_MAGENTO_URL         = ENV["MBK_MAGENTO_URL"]
MBK_MAGENTO_USER        = ENV["MBK_MAGENTO_USER"]
MBK_MAGENTO_PASS        = ENV["MBK_MAGENTO_PASS"]
MBK_MAGENTO_SOAP_USER   = ENV["MBK_MAGENTO_SOAP_USER"]
MBK_MAGENTO_SOAP_APIKEY = ENV["MBK_MAGENTO_SOAP_APIKEY"]


MBK_XML_MAX_FILE_SIZE   = ENV["MBK_XML_MAX_FILE_SIZE"]
MBK_XML_PART_DIR        = ENV["MBK_XML_PART_DIR"]
MBK_DB_HOST             = ENV["MBK_DB_HOST"]
MBK_DB_USER             = ENV["MBK_DB_USER"]
MBK_DB_PASS             = ENV["MBK_DB_PASS"]

MBK_ADMIN_EMAIL         = ENV["MBK_ADMIN_EMAIL"]

#Array of arrays for ["<appname>", <freq in minutes>]
#60 -> 1 hr, 720 -> 12 hrs, 1440 -> 24 hrs, 2160 -> 36 hrs
MBK_APP_AND_RUN_FREQ    = [ ["scripts/v_csv2site.rb", 30],
                            ["scripts/v_mysql2csv.rb", 30],
                            ["scripts/v_get_column_data.rb", 1800 ],
                            ["scripts/v_site2xml.rb", 1800],
                            ["scripts/v_xml2mysql.rb", 3]]
