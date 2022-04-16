DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_load_tables`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_load_tables` (in srcdb varchar(64), in dstdb varchar(64))
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
    DISTINCT (s.TABLE_NAME)
from
    npii.pii2 s
where
    s.TABLE_SCHEMA = srcdb
order by
    s.TABLE_NAME;



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

declare continue HANDLER for not found
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
		call npii_get_table_cols(srcdb, tablename_val, 'TBLOAD', @tbl_columns, @tbl_prikeys);
		select concat("create table ",dstdb,'.',tablename_val,' as select ') as '/* create target */' ;
		select concat(@tbl_prikeys,',',@tbl_columns) as '/* insert columns */';
		select concat('from ',srcdb,'.',tablename_val,';') as '-- end load';
		select concat('alter table ',dstdb,'.',c.table_name,' modify ',c.column_name,' ',c.column_type,' not null primary key;') into cmd 
		FROM information_schema.columns c where c.table_schema = srcdb AND c.table_name=tablename_val AND c.column_key = 'PRI';
		if cmd <> '' then
			select cmd as '-- alter:';
	--		set @sql = cmd;
	--		prepare STMT from @sql;
	--		execute STMT;
	--		deallocate prepare STMT;
		end if;
	end if;
end loop the_loop;
 commit;
end;

;;
