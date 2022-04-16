DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_execute`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_execute` (in `cmd` text)
    MODIFIES SQL DATA
    COMMENT 'prepare and execute SQL statement'
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

	if cmd <> '' then
		set @sql = cmd;
		prepare STMT from @sql;
		execute STMT;
		deallocate prepare STMT;
	else
		select " -- WARNING: empty command passed to CALL npii_execute('')" as '# warning';
	end if;
end;

;;
