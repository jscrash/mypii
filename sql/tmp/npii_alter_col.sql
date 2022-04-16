DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_alter_col`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_alter_col` (in srcdb varchar(64), in dstdb varchar(64))
begin
declare num_rows int default 0;
declare tablename_val varchar(64);
declare schema_name varchar(64);
declare cmd_info varchar(255);
declare cmd varchar(255);
declare no_more_rows boolean;

declare alter_cur cursor for select concat('alter table ',dstdb,'.',table_name,' MODIFY ',column_name,' varchar(300);')
        FROM npii.pii2 WHERE lower(table_schema) = lower(srcdb);

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

declare continue HANDLER for not FOUND
    set no_more_rows = true;
start transaction;
open alter_cur;
select FOUND_ROWS() into num_rows;
the_loop: loop fetch alter_cur INTO cmd; 
if no_more_rows then 
    close alter_cur; 
    leave the_loop;
end if;
    
    if cmd <> '' then 
	select cmd as '-- note:'; 
--	SET @sql = cmd; 
--	prepare STMT FROM @sql;
--	execute STMT; 
--	deallocate prepare STMT;
    end if;
end loop the_loop;

commit;

END;

;;
