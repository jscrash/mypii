DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_msg_quote`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_msg_quote` (in msg varchar(255))
    COMMENT 'quote message for user by "-- INFO:" prefix'
begin
    
    select concat('SELECT "-- INFO: ', msg, '" AS "-- INFO:";') as '-- INFO:';
end;

;;
