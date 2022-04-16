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
