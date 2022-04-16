--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_sync_table_engines`;
delimiter ;;
create definer=current_user procedure `npii_sync_table_engines` (in srcdb varchar(64), in dstdb varchar(64))
begin
declare num_rows int default 0;
declare tablename_val varchar(64);
declare schema_name varchar(64);
declare cmd_info varchar(255);
declare cmd varchar(255);
declare no_more_rows boolean;

declare sync_engine_cur cursor for
	select 	s.table_name,
		concat('/* alter table `', dstdb, '`.`', s.table_name, '` */') as cmd_info,
		concat('alter table `', dstdb, '`.`', s.table_name, '` engine = ', s.engine) as cmd
	from information_schema.tables as s
		inner join information_schema.tables as d on
			( s.table_name = d.table_name and d.table_schema = dstdb and s.engine <> d.engine )
		where s.table_schema = srcdb;
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
open sync_engine_cur;
select found_rows() into num_rows;
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
	prepare stmt from @sql;
	execute stmt;
	deallocate prepare stmt;
    end if;
end loop the_loop;

commit;

end;

;;

