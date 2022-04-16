--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_create_triggers`;
delimiter ;;
create definer=current_user procedure `npii_create_triggers` (in srcdb varchar(64), in dstdb varchar(64))
begin
declare tablename_val varchar(64);
declare schema_name varchar(64);
declare cmd_info varchar(255);
declare cmd varchar(255);
declare t_type varchar(16);
declare t_name varchar(255);
declare no_more_rows boolean;
declare `missing_triggers_cur` cursor for
	select 
    distinct (s.table_name),
    trigger_types.t_type,
    concat('npii_', lower(trigger_types.t_type), '_', s.table_name) as t_name
from
    npii.pii2 s
inner join (
    select
        'insert' as t_type
union
    select
        'update' as t_type
union
    select
        'delete' as t_type ) as trigger_types
left join information_schema.triggers as t on
    ( s.table_schema = t.event_object_schema
    and s.table_name = t.event_object_table
    and trigger_types.t_type = t.event_manipulation )
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
select 'select database() into @cur_schema;' as '-- info: current schema is:'
union
select concat('use `', srcdb, '`;');
start transaction;
open missing_triggers_cur;
the_loop: loop fetch missing_triggers_cur into
    tablename_val,
    t_type,
    t_name;
if no_more_rows then
close missing_triggers_cur;
leave the_loop;
end if;
call npii_execute(concat( 'select "drop trigger if exists `', t_name, '`;" as "select \' -- info: drop & create trigger `', t_name, '`\' as \'-- info:\'; ";'));

    case t_type
    when 'insert' then select '-- info: create insert trigger' as '-- info:';

	select concat(" create definer = current_user trigger `", t_name, "` after insert on `", tablename_val,
	    "` for each row begin insert into `", dstdb, "`.`", tablename_val, "` set " ) as 'delimiter ;;' ;

	call npii_get_table_cols(srcdb, tablename_val, 'insert', @tbl_columns, @tbl_prikeys);

	if length(@tbl_prikeys) > 0 then
	    select @tbl_columns as '/* insert columns */'
	    union select ', /* --- pk separator --- */'
	    union select @tbl_prikeys;
	else
	    select @tbl_columns as '/* insert columns */';
	end if;

	select ' ; end ;' as '/* end of insert trigger */'
	union select ';;'
	union select 'delimiter ;';

    when 'update' then select '-- info: create update trigger' as '-- info:';
    select concat(" create definer = current_user trigger `", t_name, "` after update on `", tablename_val,
    	"` for each row begin update `", dstdb, "`.`", tablename_val, "` set " ) as 'delimiter ;;' ;

    call npii_get_table_cols(srcdb, tablename_val, 'update', @tbl_columns, @tbl_prikeys);

    select @tbl_columns as '/* update columns */'
    union select 'where /* --- pk separator --- */'
    union select @tbl_prikeys;

    select ' ; end ;' as '/* end of update trigger */'
    union select ';;'
    union select 'delimiter ;';
    when 'delete' then select '-- info: create delete trigger' as '-- info:';

    select concat(" create definer = current_user trigger `", t_name, "` after delete on `", tablename_val,
    	"` for each row begin delete from `", dstdb, "`.`", tablename_val, "` " ) as 'delimiter ;;' ;

    call npii_get_table_cols(srcdb, tablename_val, 'delete', @tbl_columns, @tbl_prikeys);

    select @tbl_prikeys as 'where /* --- pk separator --- */';

    select ' limit 1 ; end ;' as '/* end of delete trigger */'
    union select ';;'
    union select 'delimiter ;';
else
    select concat('-- error: wrong trigger type " ', t_type, ' "') as '# error';
end case;

if cmd <> '' then
    select cmd;
end if;
end loop the_loop;

--	select 'use @cur_schema;' as ' -- skip: switch back to';

 commit;
end;

;;
