DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_sync_table_engines`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_sync_table_engines` (in srcdb varchar(64), in dstdb varchar(64))
begin
declare num_rows int default 0;
declare tablename_val varchar(64);
declare schema_name varchar(64);
declare cmd_info varchar(255);
declare cmd varchar(255);
declare no_more_rows boolean;

declare sync_engine_cur cursor for
	select 	s.TABLE_NAME,
		concat('/* ALTER TABLE `', dstdb, '`.`', s.TABLE_NAME, '` */') as cmd_info,
		concat('ALTER TABLE `', dstdb, '`.`', s.TABLE_NAME, '` ENGINE = ', s.ENGINE) as cmd
	from information_schema.TABLES as s
		inner join information_schema.TABLES as d on
			( s.TABLE_NAME = d.TABLE_NAME and d.TABLE_SCHEMA = dstdb and s.ENGINE <> d.ENGINE )
		where s.TABLE_SCHEMA = srcdb;
declare exit HANDLER for sqlexception
BEgin
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
open sync_engine_cur;
select FOUND_ROWS() into num_rows;
the_loop: loop fetch sync_engine_cur into
        tablename_val,
        cmd_info,
        cmd;
    if no_more_rows then
	close sync_engine_cur;
	leave the_loop;
    end if;
    
    if cmd <> '' then
	select cmd as '-- note:';
	set @sql = cmd;
	prepare STMT from @sql;
	execute STMT;
	deallocate prepare STMT;
    end if;
end loop the_loop;

commit;

end;

;;

