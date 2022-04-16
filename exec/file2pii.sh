DB=$1

#--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019

. ./database.mk
MYSQL="mysql -h$MYSQLHOST -u$MYSQLUSER -p$MYSQLPW -P$MYSQLPORT "

$MYSQL information_schema -s <<EOFEOF > /tmp/env.file2pii
select count(*) into @schema from schemata where  schema_name = 'npii';
select concat('npiischema=',@schema);
select count(*) into @piitab from tables where table_name = 'pii' and table_schema = 'npii';
select concat('piitabinstalled=',@piitab);
EOFEOF

eval `cat /tmp/env.file2pii`
if [ "$npiischema" == "0" ]; then
	echo "npii not installed. "
	echo "You need to run 'make install'"
	exit
fi
if [ "$piitabinstalled" != "0" ]; then
	$MYSQL npii -e 'select * from pii' -B | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > pii-bak.csv
fi
tr -d '"' < pii.csv | exec/file2pii.awk | $MYSQL npii

