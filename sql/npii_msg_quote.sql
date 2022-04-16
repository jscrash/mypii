--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_msg_quote`;
delimiter ;;
create definer=current_user procedure `npii_msg_quote` (in msg varchar(255))
    comment 'quote message for user by "-- info:" prefix'
begin
    
    select concat('select "-- info: ', msg, '" as "-- info:";') as '-- info:';
end;

;;
