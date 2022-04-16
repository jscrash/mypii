#!/bin/bash

#--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019

DB=$1
RED="\\033[1;31m"
GREEN="\\033[1;32m"
YELLOW="\\033[1;33m"
BLUE="\\033[1;34m"
PURPLE="\\033[1;35m"
CYAN="\\033[1;36m"
GREY="\\033[1;37m"
NORMAL="\\033[0;38m"
LIGHTRED="\\033[1;31m"
LIGHTGREEN="\\033[1;32m"
LIGHTYELLOW="\\033[0;33m"
LIGHTBLUE="\\033[1;34m"
LIGHTPURPLE="\\033[1;35m"
LIGHTCYAN="\\033[1;36m"
LIGHTGREY="\\033[1;37m"
BLINKSTART="\\033[5m"
BLINKSTOP="\\033[25m"
$DB information_schema -s <<EOFEOF > /tmp/env.check
select count(*) into @schema from schemata where  schema_name = 'npii';
select concat('npiischema=',@schema);
select count(*) into @piitab from tables where table_name = 'pii' and table_schema = 'npii';
select concat('piitabinstalled=',@piitab);
select count(*) into @numpolicytriggers from triggers where trigger_name like 'npii_%' and event_object_schema = 'policy_service';
select concat('numpolicytriggers=',@numpolicytriggers);
select count(*) into @numquotetriggers from triggers where trigger_name like 'npii_%' and event_object_schema = 'quote_service';
select concat('numquotetriggers=',@numquotetriggers);
EOFEOF

#cat /tmp/env.check
eval `cat /tmp/env.check`
/bin/echo -e " "
if [ "$npiischema" == "0" ]; then
	/bin/echo -e "${RED}npii not installed.  No pii table found."
	/bin/echo -e "${NORMAL}You need to run ${BLINKSTART}make install${BLINKSTOP}'"
	exit
else 
	/bin/echo -en "[${GREEN}npii installed${NORMAL}]  "
fi

if [ "$numpolicytriggers" == "0" ]; then
	/bin/echo -en "[${BLINKSTART}${RED}Policy Service${BLINKSTOP}${NORMAL}]  " 
else
	/bin/echo -en "[${GREEN}Policy Service${NORMAL}]  " 
fi

if [ "$numquotetriggers" == "0" ]; then
	/bin/echo -e "[${BLINKSTART}${RED}Quote Service${BLINKSTOP}${NORMAL}]  " 
else

	/bin/echo -e "[${GREEN}Quote Service${NORMAL}]  " 
fi

if [ "$npiischema" != "0" ]; then
	echo " "
	/bin/echo -e  " Current pii definitions are:  (use ${CYAN}make editpii${NORMAL} to modify)"
	/bin/echo -e "${GREY}Database       Table     Column $NORMAL "
	/bin/echo -en ""
	$DB npii --pager='less -SFX'  --line-numbers --skip-column-name <<EOFEOF2 2>/dev/null
select * from npii.pii;
EOFEOF2
	/bin/echo -e "${NORMAL}"
fi

if [ "$numpolicytriggers" == "0" ]; then
	/bin/echo -e "policy_service is not configured,  Use ${CYAN}make policy_service${NORMAL}"  
else
	/bin/echo -e "${GREEN}There are $numpolicytriggers active triggers for policy service.${NORMAL}"
fi

if [ "$numquotetriggers" == "0" ]; then
	/bin/echo -e "quote_service is not configured,  Use  ${CYAN}make quote_service${NORMAL}"  
else
	/bin/echo -e "${GREEN}There are $numquotetriggers active triggers for quote service.${NORMAL}"
fi

