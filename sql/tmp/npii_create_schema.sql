DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_create_schema`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_create_schema` (in dstdb varchar(64))
begin
    declare num_rows int default 0;
    declare get_schema_name_cur cursor for 
        select SCHEMA_NAME from information_schema.SCHEMATA
        where SCHEMA_NAME = dstdb;

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

start transaction;
open get_schema_name_cur;
select FOUND_ROWS() INTO num_rows;
if num_rows then
    close get_schema_name_cur;
else
    set @sql = concat('CREATE DATABASE `', dstdb, '`;');
    select @sql as '-- note:';
--  prepare STMT from @sql;
--  execute STMT;
--  deallocate prepare STMT;
end if;
 commit;
    
end;

;;
