--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_load_tables`;
delimiter ;;
create definer=current_user procedure `npii_load_tables` (in srcdb varchar(64), in dstdb varchar(64))
begin
declare tablename_val varchar(64);
declare schema_name varchar(64);
declare cmd_info varchar(255);
declare cmd varchar(255);
declare t_type varchar(16);
declare t_name varchar(255);
declare no_more_rows boolean;
declare `tables_cur` cursor for
	select 
    distinct (s.table_name)
from
    npii.pii2 s
where
    s.table_schema = srcdb
order by
    s.table_name;



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
open tables_cur;
the_loop: loop fetch tables_cur into
    tablename_val;
if no_more_rows then
	close tables_cur;
	leave the_loop;
end if;
	call sys.table_exists(dstdb,tablename_val,@exists);
	if length(@exists) > 0  then
		select '-- driver exists... skipping' as '-- skip';
	else
		call npii_get_table_cols(srcdb, tablename_val, 'tbload', @tbl_columns, @tbl_prikeys);
		select concat("create table ",dstdb,'.',tablename_val,' as select ') as '/* create target */' ;
		select concat(@tbl_prikeys,',',@tbl_columns) as '/* insert columns */';
		select concat('from ',srcdb,'.',tablename_val,';') as '-- end load';
		select concat('alter table ',dstdb,'.',c.table_name,' modify ',c.column_name,' ',c.column_type,' not null primary key;') into cmd 
		from information_schema.columns c where c.table_schema = srcdb and c.table_name=tablename_val and c.column_key = 'pri';
		if cmd <> '' then
			select cmd as '-- alter:';
	--		set @sql = cmd;
	--		prepare stmt from @sql;
	--		execute stmt;
	--		deallocate prepare stmt;
		end if;
	end if;
end loop the_loop;
 commit;
end;

;;
