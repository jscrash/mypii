DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_drop_triggers`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_drop_triggers` (in srcdb varchar(64))
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
select
    concat('DROP TRIGGER IF EXISTS `npii_', lower(trigger_types.t_type), '_', s.TABLE_NAME, '`;') as 'select "-- INFO: Dropping triggers" AS "-- INFO:";'
from
    npii.pii2 s
inner join
    (
    select 'INSERT' as t_type
    union
    select 'UPDATE' as t_type
    union
    select 'DELETE' as t_type
    ) as trigger_types
left join information_schema.TRIGGERS as t
    on (s.TABLE_SCHEMA = t.EVENT_OBJECT_SCHEMA
    and s.TABLE_NAME = t.EVENT_OBJECT_TABLE
    and trigger_types.t_type = t.EVENT_MANIPULATION )
where
    s.TABLE_SCHEMA = srcdb
order by
    s.TABLE_NAME;
    select 'SELECT "-- INFO: all triggers dropped" AS "-- INFO:";' as '-- INFO';

end;

;;
