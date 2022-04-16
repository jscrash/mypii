DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_init`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_init` (in srcdb varchar(64))
begin
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
