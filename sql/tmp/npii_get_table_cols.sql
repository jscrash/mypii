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
