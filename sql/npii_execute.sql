--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_execute`;
delimiter ;;
create definer=current_user procedure `npii_execute` (in `cmd` text)
    modifies sql data
    comment 'prepare and execute sql statement'
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

	if cmd <> '' then
		set @sql = cmd;
		prepare stmt from @sql;
		execute stmt;
		deallocate prepare stmt;
	else
		select " -- warning: empty command passed to call npii_execute('')" as '# warning';
	end if;
end;

;;
