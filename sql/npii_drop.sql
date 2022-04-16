--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_drop`;
delimiter ;;
create definer=current_user procedure `npii_drop` (in srcdb varchar(64), in dstdb varchar(64))
    comment 'drop replicated schema'
begin
    declare continue handler for 1008 set @ignored = yes;
    select 'start transaction;' as '-- sql command';
    call npii_drop_triggers(srcdb);
    select concat('drop database if exists `', dstdb, '`;') as '-- sql command'
    union select 'commit;' as '-- now do the job';
    call npii_msg_quote(concat('database `', dstdb, '`, dropped'));
end;

;;
