DB=$1

#--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
. ./database.mk
MYSQL="mysql -h$MYSQLHOST -u$MYSQLUSER -p$MYSQLPW -P$MYSQLPORT "

$MYSQL information_schema -s <<EOFEOF > /tmp/env.install_npii
select count(*) into @schema from schemata where  schema_name = 'npii';
select concat('npiischema=',@schema);
select count(*) into @piitab from tables where table_name = 'pii' and table_schema = 'npii';
select concat('piitabinstalled=',@piitab);
EOFEOF

eval `cat /tmp/env.install_npii`
if [ "$npiischema"  == "1" ]; then
	echo "Reinstalling NPII.  The current pii definitions will be reused."
	if [ "$piitabinstalled" != "0"  ]; then
		echo "exporting pii table to ./pii.csv"
		$MYSQL npii -e 'select * from pii' -B | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > pii.csv
	fi
else
	echo "Creating NPII schema."
	$MYSQL -e 'create database npii;'
fi
echo "Installing NPII stored procedures."
(cd sql; $MYSQL npii --comments < ./install_npii.sql )
exec/file2pii.sh

