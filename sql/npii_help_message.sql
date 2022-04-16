--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
delimiter ;
drop procedure if exists `npii_help_message`;
delimiter ;;
create definer=current_user procedure `npii_help_message` (out help_message text)
begin


    select  '
     
    noblr personally identifiable information (npii) protection tool.

    npii is implemented as a library of stored procedures that exist in
    a mysql database called npii that is located on the server that has
    the database(s) which contain the sensitive data we want to hide.
    a table called pii that is located in the npii database contains the
    description of the tables and columns that will be processed as pii
    and stored seperately from the main database in a database called
    <main database name>_pii.

    each of the commands below take a srcdb or a dstdb or both as arguments.
	    
 srcdb 
     is the primary production database.  the data in srcdb is never touched.
     it is used for reference while creating a shadow schema that contains
     selected tables that have some columns encrypted.
 dstdb is the pii schema that is created.  it is always named srcdb + ''_pii''
     so if srcdb = ''policy_service'' then dstdb is policy_service_pii.
     the structure of policy_service.driver is examined to assemble the metadata
     needed to make a matching policy_service_pii.driver table for example.
     triggers are created in srcdb for selected tables so that changes to
     them are reflected in the dstdb.
     
 
 call npii.npii_init(in:srcdb)
     create a pii schema and tables for the given srcdb based on the configuration
     in the pii table.  to test without making any changes, run this way: 

       echo "call npii.npii_init(''policy_service'');" | mysql -usuperuser -p

     this will generate the script and display it but not execute it. a dry-run.
     useful to see what will be done.   to actually run and make the pii schema
     run like this:
  
       echo "call npii.npii_init(''policy_service'');" | mysql -uproduser | mysql -uproduser
  
    this will generate the pii schema, load tables with encrypted pii columns and set triggers 
    to maintain them.


 call npii.npii_drop(in:srcdb,in:dstdb)
    this will remove the triggers from the srcdb and then drop the pii schema dstdb.


 call npii.npii_drop_triggers(in:srcdb)
    this will remove the triggers from srcdb but not drop the pii schema.  no data is removed from dstdb 
    however without the triggers in place the pii schema will become out of date since it is no longer 
    getting changes/inserts etc.


 call npii.npii_help()
    this is how you got this help screen.


 internal support procedures.  not meant to be called directly.

 call npii.npii_execute(in:cmd)
 call npii.npii_help_message(in:text)
 call npii.npii_msg_quote(in:msg)
 call npii.npii_create_schema(in:dstdb)
 -- call npii.npii_create_tables(in:srcdb,in:dstdb)
 call npii.npii_load_tables(in:srcdb,in:dstdb)
 call npii.npii_create_triggers(in:srcdb,in:dstdb)
 call npii.npii_sync_table_engines(in:srcdb,in:dstdb)
 call npii.npii_get_table_cols(in:tbl_schema,in:tbl_table,in:trg_type,out:prikeys,out:columns)
 call npii.npii_alter_col(in:srcdb,in:dstdb)
    ' into help_message;

end;

;;
