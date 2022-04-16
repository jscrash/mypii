DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_create_triggers`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_create_triggers` (in srcdb varchar(64), in dstdb varchar(64))
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
    DISTINCT (s.TABLE_NAME),
    trigger_types.t_type,
    concat('npii_', lower(trigger_types.t_type), '_', s.TABLE_NAME) as t_name
from
    npii.pii2 s
inner join (
    select
        'INSERT' as t_type
union
    select
        'UPDATE' as t_type
union
    select
        'DELETE' as t_type ) as trigger_types
left join information_schema.TRIGGERS as t on
    ( s.TABLE_SCHEMA = t.EVENT_OBJECT_SCHEMA
    and s.TABLE_NAME = t.EVENT_OBJECT_TABLE
    and trigger_types.t_type = t.EVENT_MANIPULATION )
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
select 'SELECT database() INTO @cur_schema;' as '-- INFO: current schema is:'
union
select concat('USE `', srcdb, '`;');
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
call npii_execute(concat( 'select "DROP TRIGGER IF EXISTS `', t_name, '`;" AS "SELECT \' -- INFO: drop & create trigger `', t_name, '`\' as \'-- INFO:\'; ";'));

    case t_type
    when 'INSERT' then select '-- INFO: create INSERT trigger' as '-- INFO:';

	select concat(" create definer = current_user trigger `", t_name, "` after insert on `", tablename_val,
	    "` for each row begin insert into `", dstdb, "`.`", tablename_val, "` set " ) as 'DELIMITER ;;' ;

	call npii_get_table_cols(srcdb, tablename_val, 'INSERT', @tbl_columns, @tbl_prikeys);

	if length(@tbl_prikeys) > 0 then
	    select @tbl_columns as '/* insert columns */'
	    union select ', /* --- PK separator --- */'
	    union select @tbl_prikeys;
	else
	    select @tbl_columns as '/* insert columns */';
	end if;

	select ' ; END ;' as '/* end of insert trigger */'
	union select ';;'
	union select 'DELIMITER ;';

    when 'UPDATE' then select '-- INFO: create UPDATE trigger' as '-- INFO:';
    select concat(" create definer = current_user trigger `", t_name, "` after update on `", tablename_val,
    	"` for each row begin update `", dstdb, "`.`", tablename_val, "` set " ) as 'DELIMITER ;;' ;

    call npii_get_table_cols(srcdb, tablename_val, 'UPDATE', @tbl_columns, @tbl_prikeys);

    select @tbl_columns as '/* update columns */'
    union select 'WHERE /* --- PK separator --- */'
    union select @tbl_prikeys;

    select ' ; END ;' as '/* end of update trigger */'
    union select ';;'
    union select 'DELIMITER ;';
    when 'DELETE' then select '-- INFO: create DELETE trigger' as '-- INFO:';

    select concat(" create definer = current_user trigger `", t_name, "` after delete on `", tablename_val,
    	"` for each row begin delete from `", dstdb, "`.`", tablename_val, "` " ) as 'DELIMITER ;;' ;

    call npii_get_table_cols(srcdb, tablename_val, 'DELETE', @tbl_columns, @tbl_prikeys);

    select @tbl_prikeys as 'WHERE /* --- PK separator --- */';

    select ' LIMIT 1 ; END ;' as '/* end of delete trigger */'
    union select ';;'
    union select 'DELIMITER ;';
else
    select concat('-- ERROR: wrong trigger type " ', t_type, ' "') as '# error';
end case;

if cmd <> '' then
    select cmd;
end if;
end loop the_loop;

--	select 'USE @cur_schema;' as ' -- SKIP: switch back to';

 commit;
end;

;;
