--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_drop_all_triggers`;
delimiter ;;
create definer=current_user procedure `npii_drop_all_triggers` (in srcdb varchar(64))
begin
declare exit handler for sqlexception
begin
    show errors;
    rollback;
end;
declare exit handler for sqlwarning
begin
    show warnings;
    rollback;
end;

    select concat('drop trigger if exists ',trigger_schema,'.',trigger_name,';') as ''
	from information_schema.triggers where trigger_name like 'npii_%' and trigger_schema = srcdb;

end;

;;
