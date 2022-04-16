DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_help`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_help` ()
    COMMENT 'print help message'
begin
--    declare help_message text;
    call npii_help_message(@help_message);
	select @help_message as '';


--    select concat("SELECT '' AS '-- INFO'
--   union
--  select'", replace(help_message, '\n', "'
-- union
-- select '"), "';" ) into @sql;

--   prepare STMT from @sql;
--   execute STMT;
--   deallocate prepare STMT;
end;

;;
