--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_drop_triggers`;
delimiter ;;
create definer=current_user procedure `npii_drop_triggers` (in srcdb varchar(64))
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
select
    concat('drop trigger if exists `npii_', lower(trigger_types.t_type), '_', s.table_name, '`;') as 'select "-- info: dropping triggers" as "-- info:";'
from
    npii.pii2 s
inner join
    (
    select 'insert' as t_type
    union
    select 'update' as t_type
    union
    select 'delete' as t_type
    ) as trigger_types
left join information_schema.triggers as t
    on (s.table_schema = t.event_object_schema
    and s.table_name = t.event_object_table
    and trigger_types.t_type = t.event_manipulation )
where
    s.table_schema = srcdb
order by
    s.table_name;
    select 'select "-- info: all triggers dropped" as "-- info:";' as '-- info';

end;

;;
