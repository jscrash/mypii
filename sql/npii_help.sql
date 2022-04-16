--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_help`;
delimiter ;;
create definer=current_user procedure `npii_help` ()
    comment 'print help message'
begin
--    declare help_message text;
    call npii_help_message(@help_message);
	select @help_message as '';


--    select concat("select '' as '-- info'
--   union
--  select'", replace(help_message, '\n', "'
-- union
-- select '"), "';" ) into @sql;

--   prepare stmt from @sql;
--   execute stmt;
--   deallocate prepare stmt;
end;

;;
