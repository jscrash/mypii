DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_drop_all_triggers`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_drop_all_triggers` (in srcdb varchar(64))
begin
declare exit HANDLER for sqlexception
begin
    show ERRORS;
    ROLLBACK;
end;
declare exit HANDLER for sqlwarning
begin
    show WARNINGS;
    ROLLBACK;
end;

    select concat('drop trigger if exists ',trigger_schema,'.',trigger_name,';') as ''
	from information_schema.triggers where trigger_name like 'npii_%' and trigger_schema = srcdb;

end;

;;
