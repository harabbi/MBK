
#Check for messages with errors:

#Mark clean runs as read
create temporary table mbk.t_uuid (select uuid from mbk.log where message like "successfully finished" and uuid in (select uuid from mbk.log where `read`="0" and message="started"));
update mbk.log set `read`=1 where uuid in (select uuid from mbk.t_uuid);
drop table mbk.t_uuid;

#Look for runs that haven't finished that are older than 2 hrs

