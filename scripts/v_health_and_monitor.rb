$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)
 
require 'mbk_utils.rb'

#_______________________________________________________________________________
at_exit do
  if $!.nil? || $!.is_a?(SystemExit) && $!.success?
    mbkloginfo(__FILE__, 'successfully finished')
  else
    code = $!.is_a?(SystemExit) ? $!.status : 1
    mbklogerr(__FILE__, "unseccessful failure with code #{code}")
  end
end

mbk_app_init(__FILE__)

#Clean out entries older than 7 days except error messages
$con.execute('delete from `mbk`.`log` where tm < date_sub(now(), interval 7 day)')
$con.execute('delete from `mbk`.`log` where tm < date_sub(now(), interval 3 day) and `read`=1')

#Check for messages with errors:
rs = $con.select_all('select * from `mbk`.`log` where `read`=0 and `logtype`="ERROR"')

email_body = "The following errors were found...\n\n"
rs.each do |r|
  email_body << "At #{r["tm"]}, #{r["appname"]}(PID: #{r["pid"]}) caused an error!\n\n#{r["message"]}"
end
email_body << "-----End of Error Report-----"

mbk_send_mail("#{rs.count} ERRORS IN LOG", email_body) unless rs.count == 0

#Mark the errors read
$con.execute('update mbk.log set `read`=1 where `read`=0 and `logtype`="ERROR"')

#Mark clean runs as read
$con.execute('create temporary table mbk.t_uuid (select uuid from mbk.log where message like "successfully finished" and uuid in (select uuid from mbk.log where `read`="0" and message="started"))')
$con.execute('update mbk.log set `read`=1 where uuid in (select uuid from mbk.t_uuid)')
$con.execute('drop table mbk.t_uuid')

#Look for runs that haven't finished that are older than 2 hrs
$con.execute('create temporary table mbk.t_uuid (select uuid from mbk.log where `read`=0 and message="started" and tm < date_sub(now(), interval 2 hour))')
message = ""
$con.select_all('select * from mbk.log where `read`=0 and message="started" and tm < date_sub(now(), interval 2 hour)').each do |r|
  message << "#{r["appname"]}(PID: #{r["pid"]}) started at #{r["tm"]} has not reported an exit.\n\n#{r["message"]}"
end
mbk_send_mail("APP(s) STALLED OR UNCLEAN FINISH", "The following apps have not finished clean within 2 hrs of starting:\n\n#{message}") unless message.blank?

#Now mark those as read as well
$con.execute('update mbk.log set `read`=1 where uuid in (select uuid from mbk.t_uuid)')
$con.execute('drop table mbk.t_uuid')

#Check to see that each app has run recently
MBK_APP_AND_RUN_FREQ.each do |appname, frequency|
  unless $con.select_all("select * from mbk.log where `appname`='#{appname}' and message like 'successfully finished' and tm > date_sub(now(), interval #{frequency} minute)")
    mbk_send_mail("#{appname} FAIL TO RUN", "#{appname} has not had a successful run in the last #{frequency} minutes.")
  end
end
