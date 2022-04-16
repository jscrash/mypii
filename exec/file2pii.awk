#!/usr/bin/awk -f

#--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019

BEGIN { FS=","
    print "use npii;"
    print "drop table if exists npii.pii;"
    print "create table if not exists npii.pii (table_schema varchar(64),table_name varchar(64),column_name varchar(64),primary key (table_schema,table_name,column_name));"
}
/^--/ {next;}
/^#/ { next; }

/table_schema,table_name,column_name/ {
    hdr=$0;
    next;
}
 {
    printf("insert ignore into npii.pii (%s) values ('%s','%s','%s');\n",hdr,$1,$2,$3);
}
