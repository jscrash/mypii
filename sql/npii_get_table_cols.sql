--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_get_table_cols`;
delimiter ;;
create definer=current_user procedure `npii_get_table_cols` (in tbl_schema varchar(32), in tbl_table varchar(64), in trg_type char(6), out tbl_columns text, out tbl_prikeys text)
begin
declare num_indexes int default 0;
declare colname varchar(255);
declare column_key varchar(3);
declare no_more_rows boolean;
declare col_sep varchar(9);
declare key_sep varchar(9);
declare nxt_sep varchar(9);

declare tbl_colums_cur cursor for
    select c.column_name, c.column_key from information_schema.columns as c
    where c.table_schema = tbl_schema and c.table_name = tbl_table
    order by c.column_key desc, c.ordinal_position;
declare indexes_count_cur cursor for
    select c.column_name, c.column_key from information_schema.columns as c
    where c.table_schema = tbl_schema and c.table_name = tbl_table and c.column_key = 'pri'
    order by c.ordinal_position;
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

set tbl_columns = '';
set tbl_prikeys = '';
set col_sep = '` = new.`';
set key_sep = '` = old.`';
set nxt_sep = ' and ';
open indexes_count_cur;
select found_rows() into num_indexes;
close indexes_count_cur;

if trg_type = 'insert' then
    set key_sep = '` = new.`';
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
     if (exists(select 1 from npii.pii2 where table_schema = tbl_schema and table_name = tbl_table and column_name = colname)) then
       set @piicol = true;
       end if;     
    if num_indexes =0 and trg_type = 'tbload' then
       case @piicol when true then
	    set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), ' md5(`',colname, '`) as ',colname); 
	else
	    set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '),  colname);
	end case;
    
    elseif num_indexes = 0 and trg_type != 'insert' and trg_type != 'tbload' then
       case @piicol when true then
	    set tbl_prikeys = concat(tbl_prikeys, if(tbl_prikeys = '', '', nxt_sep), '`', colname,'` = md5(new.`',colname, '`)');  
	    set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), '`', colname,'` = md5(new.`',colname, '`)'); 
	else
	    set tbl_prikeys = concat(tbl_prikeys, if(tbl_prikeys = '', '', nxt_sep), '`', colname, key_sep, colname, '`');
	    set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), '`', colname, col_sep, colname, '`');
	end case;
    elseif trg_type = 'tbload' then
	case column_key when 'pri' then
            set tbl_prikeys = 
                concat(tbl_prikeys, if(tbl_prikeys = '', '', nxt_sep),colname, ' /* pk */ ');
        else 
	    case @piicol when true then
		set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), ' md5(`',colname, '`) as ',colname); 
	    else
		set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), '`', colname, '`');
	    end case;
        end case ;
    elseif trg_type != 'tbload' then
        case column_key when 'pri' then
            set tbl_prikeys = 
                concat(tbl_prikeys, if(tbl_prikeys = '', '', nxt_sep), '`', colname, key_sep, colname, '`', ' /* pk */ ');
        else 
	    case @piicol when true then
		set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), '`', colname,'` = md5(new.`',colname, '`)'); 
	    else
		set tbl_columns = concat(tbl_columns, if(tbl_columns = '', '', ', '), '`', colname, col_sep, colname, '`');
	    end case;
        end case ;
    end if;
end loop the_loop;
end;

;;
