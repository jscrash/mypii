DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_drop`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_drop` (in srcdb varchar(64), in dstdb varchar(64))
    COMMENT 'drop replicated schema'
begin
    declare CONTINUE handler for 1008 set @ignored = yes;
    select 'START TRANSACTION;' as '-- SQL command';
    call npii_drop_triggers(srcdb);
    select concat('DROP DATABASE if exists `', dstdb, '`;') as '-- SQL command'
    union select 'COMMIT;' as '-- now do the job';
    call npii_msg_quote(concat('database `', dstdb, '`, dropped'));
end;

;;
