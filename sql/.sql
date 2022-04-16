use npii;

DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_alter_col`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_alter_col` (in srcdb varchar(64), in dstdb varchar(64))
begin
declare num_rows int default 0;
declare tablename_val varchar(64);
declare schema_name varchar(64);
declare cmd_info varchar(255);
declare cmd varchar(255);
declare no_more_rows boolean;

declare alter_cur cursor for select concat('alter table ',dstdb,'.',table_name,' MODIFY ',column_name,' varchar(300);')
        FROM npii.pii2 WHERE lower(table_schema) = lower(srcdb);

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

declare continue HANDLER for not FOUND
    set no_more_rows = true;
start transaction;
open alter_cur;
select FOUND_ROWS() into num_rows;
the_loop: loop fetch alter_cur INTO cmd; 
if no_more_rows then 
    close alter_cur; 
    leave the_loop;
end if;
    
    if cmd <> '' then 
	select cmd as '-- note:'; 
--	SET @sql = cmd; 
--	prepare STMT FROM @sql;
--	execute STMT; 
--	deallocate prepare STMT;
    end if;
end loop the_loop;

commit;

END;

;;

DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_create_schema`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_create_schema` (in dstdb varchar(64))
begin
    declare num_rows int default 0;
    declare get_schema_name_cur cursor for 
        select SCHEMA_NAME from information_schema.SCHEMATA
        where SCHEMA_NAME = dstdb;

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

start transaction;
open get_schema_name_cur;
select FOUND_ROWS() INTO num_rows;
if num_rows then
    close get_schema_name_cur;
else
    set @sql = concat('CREATE DATABASE `', dstdb, '`;');
    select @sql as '-- note:';
--  prepare STMT from @sql;
--  execute STMT;
--  deallocate prepare STMT;
end if;
 commit;
    
end;

;;


DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_load_tables`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_load_tables` (in srcdb varchar(64), in dstdb varchar(64))
begin
declare tablename_val varchar(64);
declare schema_name varchar(64);
declare cmd_info varchar(255);
declare cmd varchar(255);
declare t_type varchar(16);
declare t_name varchar(255);
declare no_more_rows boolean;
declare `tables_cur` cursor for
	select 
    DISTINCT (s.TABLE_NAME)
from
    npii.pii2 s
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
start transaction;
open tables_cur;
the_loop: loop fetch tables_cur into
    tablename_val;
if no_more_rows then
	close tables_cur;
	leave the_loop;
end if;
	call sys.table_exists(dstdb,tablename_val,@exists);
	if length(@exists) > 0  then
		select '-- driver exists... skipping' as '-- skip';
	else
		call npii_get_table_cols(srcdb, tablename_val, 'TBLOAD', @tbl_columns, @tbl_prikeys);
		select concat("create table ",dstdb,'.',tablename_val,' as select ') as '/* create target */' ;
		select concat(@tbl_prikeys,',',@tbl_columns) as '/* insert columns */';
		select concat('from ',srcdb,'.',tablename_val,';') as '-- end load';
		select concat('alter table ',dstdb,'.',c.table_name,' modify ',c.column_name,' ',c.column_type,' not null primary key;') into cmd 
		FROM information_schema.columns c where c.table_schema = srcdb AND c.table_name=tablename_val AND c.column_key = 'PRI';
		if cmd <> '' then
			select cmd as '-- alter:';
	--		set @sql = cmd;
	--		prepare STMT from @sql;
	--		execute STMT;
	--		deallocate prepare STMT;
		end if;
	end if;
end loop the_loop;
 commit;
end;

;;


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

DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_drop_all_triggers`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_drop_all_triggers` (in srcdb varchar(64))
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

    select concat('drop trigger if exists ',trigger_schema,'.',trigger_name,';') as ''
	from information_schema.triggers where trigger_name like 'npii_%' and trigger_schema = srcdb;

end;

;;

DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_execute`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_execute` (in `cmd` text)
    MODIFIES SQL DATA
    COMMENT 'prepare and execute SQL statement'
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

	if cmd <> '' then
		set @sql = cmd;
		prepare STMT from @sql;
		execute STMT;
		deallocate prepare STMT;
	else
		select " -- WARNING: empty command passed to CALL npii_execute('')" as '# warning';
	end if;
end;

;;

DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_get_table_cols`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_get_table_cols` (in tbl_schema varchar(32), in tbl_table varchar(64), in trg_type char(6), out tbl_columns text, out tbl_prikeys text)
begin
declare num_indexes int default 0;
declare colname varchar(255);
declare column_key varchar(3);
declare no_more_rows boolean;
declare col_sep varchar(9);
declare key_sep varchar(9);
declare nxt_sep varchar(9);

declare tbl_colums_cur cursor for
    select c.COLUMN_NAME, c.COLUMN_KEY from information_schema.COLUMNS as c
    where c.TABLE_SCHEMA = tbl_schema and c.TABLE_NAME = tbl_table
    order by c.COLUMN_KEY desc, c.ORDINAL_POSITION;
declare indexes_count_cur cursor for
    select c.COLUMN_NAME, c.COLUMN_KEY from information_schema.COLUMNS as c
    where c.TABLE_SCHEMA = tbl_schema and c.TABLE_NAME = tbl_table and c.COLUMN_KEY = 'PRI'
    order by c.ORDINAL_POSITION;
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

set tbl_columns = '';
set tbl_prikeys = '';
set col_sep = '` = NEW.`';
set key_sep = '` = OLD.`';
set nxt_sep = ' AND ';
open indexes_count_cur;
select FOUND_ROWS() into num_indexes;
close indexes_count_cur;

if trg_type = 'INSERT' then
    set key_sep = '` = NEW.`';
    set nxt_sep = ', ';
end if;
open tbl_colums_cur;
the_loop: loop fetch tbl_colums_cur into
    colname, column_key;
    if no_more_rows then
        close tbl_colums_cur;
        leave the_loop;
    end if;
     set @piicol=false;
     if (exists(select 1 from npii.pii2 where table_schema = tbl_schema AND table_name = tbl_table AND column_name = colname)) THEN
       set @piicol = true;
       end if;     
    if num_indexes =0 and trg_type = 'TBLOAD' then
       case @piicol when true then
	    set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), ' md5(`',colname, '`) as ',colname); 
	else
	    set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '),  colname);
	end case;
    
    elseif num_indexes = 0 and trg_type != 'INSERT' and trg_type != 'TBLOAD' then
       case @piicol when true then
	    set tbl_prikeys = concat(tbl_prikeys, if(tbl_prikeys = '', '', nxt_sep), '`', colname,'` = md5(NEW.`',colname, '`)');  
	    set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), '`', colname,'` = md5(NEW.`',colname, '`)'); 
	else
	    set tbl_prikeys = concat(tbl_prikeys, if(tbl_prikeys = '', '', nxt_sep), '`', colname, key_sep, colname, '`');
	    set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), '`', colname, col_sep, colname, '`');
	end case;
    elseif trg_type = 'TBLOAD' then
	case column_key when 'PRI' then
            set tbl_prikeys = 
                concat(tbl_prikeys, if(tbl_prikeys = '', '', nxt_sep),colname, ' /* PK */ ');
        else 
	    case @piicol when true then
		set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), ' md5(`',colname, '`) as ',colname); 
	    else
		set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), '`', colname, '`');
	    end case;
        end case ;
    elseif trg_type != 'TBLOAD' then
        case column_key when 'PRI' then
            set tbl_prikeys = 
                concat(tbl_prikeys, if(tbl_prikeys = '', '', nxt_sep), '`', colname, key_sep, colname, '`', ' /* PK */ ');
        else 
	    case @piicol when true then
		set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), '`', colname,'` = md5(NEW.`',colname, '`)'); 
	    else
		set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), '`', colname, col_sep, colname, '`');
	    end case;
        end case ;
    end if;
end loop the_loop;
end;

;;

DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_help`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_help` ()
    COMMENT 'print help message'
begin
--    declare help_message text;
    call npii_help_message(@help_message);
	select @help_message as '';


--    select concat("SELECT '' AS '-- INFO'
--   union
--  select'", replace(help_message, '\n', "'
-- union
-- select '"), "';" ) into @sql;

--   prepare STMT from @sql;
--   execute STMT;
--   deallocate prepare STMT;
end;

;;

DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_help_message`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_help_message` (out help_message text)
begin


    select  '
     
    Noblr Personally Identifiable Information (npii) protection tool.

    Npii is implemented as a library of stored procedures that exist in
    a mysql database called npii that is located on the server that has
    the database(s) which contain the sensitive data we want to hide.
    A table called pii that is located in the npii database contains the
    description of the tables and columns that will be processed as pii
    and stored seperately from the main database in a database called
    <main database name>_pii.

    Each of the commands below take a srcdb or a dstdb or both as arguments.
	    
 SRCDB 
     Is the primary production database.  The data in SRCDB is never touched.
     It is used for reference while creating a shadow schema that contains
     selected tables that have some columns encrypted.
 DSTDB is the pii schema that is created.  It is always named SRCDB + ''_pii''
     So if SRCDB = ''policy_service'' then DSTDB is policy_service_pii.
     the structure of policy_service.driver is examined to assemble the metadata
     needed to make a matching policy_service_pii.driver table for example.
     Triggers are created in SRCDB for selected tables so that changes to
     them are reflected in the DSTDB.
     
 
 CALL npii.npii_init(in:srcdb)
     Create a pii schema and tables for the given srcdb based on the configuration
     in the pii table.  To test without making any changes, run this way: 

       echo "call npii.npii_init(''policy_service'');" | mysql -uSuperUser -p

     This will generate the script and display it but not execute it. A dry-run.
     Useful to see what will be done.   To actually run and make the pii schema
     run like this:
  
       echo "call npii.npii_init(''policy_service'');" | mysql -uproduser | mysql -uproduser
  
    This will generate the pii schema, load tables with encrypted pii columns and set triggers 
    to maintain them.


 CALL npii.npii_drop(in:srcdb,in:dstdb)
    This will remove the triggers from the srcdb and then drop the pii schema dstdb.


 CALL npii.npii_drop_triggers(in:srcdb)
    This will remove the triggers from srcdb but not drop the pii schema.  No data is removed from dstdb 
    however without the triggers in place the pii schema will become out of date since it is no longer 
    getting changes/inserts etc.


 CALL npii.npii_help()
    This is how you got this help screen.


 Internal support procedures.  Not meant to be called directly.

 CALL npii.npii_execute(in:cmd)
 CALL npii.npii_help_message(in:text)
 CALL npii.npii_msg_quote(in:msg)
 CALL npii.npii_create_schema(in:dstdb)
 -- CALL npii.npii_create_tables(in:srcdb,in:dstdb)
 CALL npii.npii_load_tables(in:srcdb,in:dstdb)
 CALL npii.npii_create_triggers(in:srcdb,in:dstdb)
 CALL npii.npii_sync_table_engines(in:srcdb,in:dstdb)
 CALL npii.npii_get_table_cols(in:tbl_schema,in:tbl_table,in:trg_type,out:PRIKEYS,out:COLUMNS)
 CALL npii.npii_alter_col(in:srcdb,in:dstdb)
    ' into help_message;

end;

;;

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

DELIMITER ;
DROP PROCEDURE IF EXISTS `npii_msg_quote`;
DELIMITER ;;
CREATE DEFINER=current_user PROCEDURE `npii_msg_quote` (in msg varchar(255))
    COMMENT 'quote message for user by "-- INFO:" prefix'
begin
    
    select concat('SELECT "-- INFO: ', msg, '" AS "-- INFO:";') as '-- INFO:';
end;

;;

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

DELIMITER ;
