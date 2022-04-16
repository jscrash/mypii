--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_init`;
delimiter ;;
create definer=current_user procedure `npii_init` (in srcdb varchar(64))
begin
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

set @dstdb=concat(srcdb,'_pii');

start transaction;
call npii_create_schema(@dstdb);
-- call npii_create_tables(srcdb, @dstdb);
call npii_sync_table_engines(srcdb, @dstdb);
call npii_load_tables(srcdb,@dstdb);
call npii_create_triggers(srcdb, @dstdb);
call npii_alter_col(srcdb,@dstdb);

commit;

end;

;;
