--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_alter_col`;
delimiter ;;
create definer=current_user procedure `npii_alter_col` (in srcdb varchar(64), in dstdb varchar(64))
begin
declare num_rows int default 0;
declare tablename_val varchar(64);
declare schema_name varchar(64);
declare cmd_info varchar(255);
declare cmd varchar(255);
declare no_more_rows boolean;

declare alter_cur cursor for select concat('alter table ',dstdb,'.',table_name,' modify ',column_name,' varchar(300);')
        from npii.pii2 where lower(table_schema) = lower(srcdb);

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

declare continue handler for not found
    set no_more_rows = true;
start transaction;
open alter_cur;
select found_rows() into num_rows;
the_loop: loop fetch alter_cur into cmd; 
if no_more_rows then 
    close alter_cur; 
    leave the_loop;
end if;
    
    if cmd <> '' then 
	select cmd as '-- note:'; 
--	set @sql = cmd; 
--	prepare stmt from @sql;
--	execute stmt; 
--	deallocate prepare stmt;
    end if;
end loop the_loop;

commit;

end;

;;
