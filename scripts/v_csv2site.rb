$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)
require 'mbk_utils.rb'
mbk_app_init(__FILE__)
$con = mbk_db_connect()
$a = mbk_volusion_login()


