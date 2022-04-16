--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_create_schema`;
delimiter ;;
create definer=current_user procedure `npii_create_schema` (in dstdb varchar(64))
begin
    declare num_rows int default 0;
    declare get_schema_name_cur cursor for 
        select schema_name from information_schema.schemata
        where schema_name = dstdb;

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

start transaction;
open get_schema_name_cur;
select found_rows() into num_rows;
if num_rows then
    close get_schema_name_cur;
else
    set @sql = concat('create database `', dstdb, '`;');
    select @sql as '-- note:';
--  prepare stmt from @sql;
--  execute stmt;
--  deallocate prepare stmt;
end if;
 commit;
    
end;

;;
