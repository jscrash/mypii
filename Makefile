# Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
#
# name of the database/schema, where you want to install SQL procedures
#
# The database.mk file that is included here must contain definitions
# for the following variables.  The variables describe a connection 
# to the Mysql database that we are installing the Npii pii schemas in.
#        DATABASE = npii
#        MYSQLHOST = piitest.cje8dnwgkfpv.us-west-2.rds.amazonaws.com
#        MYSQLUSER = mysqlprod
#        MYSQLPW = prodtest
#        MYSQLPORT = 3306
# NOTE: The database.mk file is automatically deleted 1 hour after you
# run this make.  If you take more than an hour to configure the Npii
# setup in your database then you will have to recreate the database.mk
# file again.  The idea here is not to leave files around that contain
# credentials to the production database.
include ./database.mk

MYSQLDUMP		:= mysqldump --opt --routines -u$(MYSQLUSER) -p$(MYSQLPW) -h$(MYSQLHOST) -P$(MYSQLPORT)
MYSQLDUMP_NODATA	:= mysqldump -u$(MYSQLUSER) -p$(MYSQLPW) -h$(MYSQLHOST) -P$(MYSQLPORT) \
			--no-data --skip-dump-date --skip-comments --skip-set-charset
MYSQL		:= mysql --pager='less -SFX'  -u$(MYSQLUSER) -p$(MYSQLPW) -h$(MYSQLHOST) -P$(MYSQLPORT)

.PHONY: sql/%.sql dump backup clean setup config realclean policy_service quote_service everything .deleter

.FORCE:

ifeq ($(MYSQLPW),)
$(error You must edit the database.mk and put values for the variables like MYSQLPW etc.)
endif

.deleter:
	@/bin/echo "Target database server: " $(MYSQLHOST)
ifeq (,$(wildcard .deleter))
	@touch .deleter
	@at now+2hour<<<'(exec/databasemk.sh;rm .deleter)'
else
	 @echo Note: credentials will be cleared in \
	 `expr \( $$(date +%s -d "$$(atq | head -1 | awk '{print $$2 " " $$3}')") - $$(date +%s) \) / 60` minutes.
endif

all: .deleter
	@/bin/echo ""
	@/bin/echo -e "$(NORMAL)"
	@/bin/echo -e "The following commands are available.  When in doubt use $(CYAN) $(BLINK) make check $(NORMAL) $(NOBLINK)"
	@echo ' '
	@/bin/echo -e  "make check		 - show the current state of npii"
	@/bin/echo -e  "make install   		 - install procedures into npii schema" 
	@/bin/echo -e  "make policy_service 	 - configure policy_service pii"
	@/bin/echo -e  "make quote_service 	 - configure quote_service pii"
	@/bin/echo -e  "make help		 - instructions and tips."
	@/bin/echo -e  "make edit		 - edit the pii definition table. "
	@/bin/echo -e  "make getpii		 - export the pii table to a file: ./pii.csv"
	@/bin/echo -e  "make putpii		 - import the file ./pii.csv into the pii table"
	@/bin/echo -e  "make uninstall		 - remove all traces of npii. (clean+realclean)"
	@/bin/echo -e  "make clean 		 - remove triggers, leave pii tables"
	@/bin/echo -e  "make realclean 		 - remove triggers and pii tables "
	@/bin/echo -e  "make login		 - enter mysql client"
	@/bin/echo -e  "make everything		 - do make install, make policy_service, make quote_service"
	@/bin/echo -e "$(NORMAL)"

everything::	install policy_service quote_service

	
login:	
	@$(MYSQL) mysql

pii-to-csv:
	@$(MYSQL) npii -e "select * from pii" -B | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > pii.csv

dump: dump/triggers.sql dump/procedures.sql dump/tables.sql

%.sql: .FORCE

dump/triggers.sql: .FORCE
	@mkdir -p dump
	@$(MYSQLDUMP_NODATA) --no-create-info --databases policy_service quote_service > $@
	@cat sql/_footer.sql >> $@

dump/procedures.sql: .FORCE
	@mkdir -p dump
	$(MYSQLDUMP_NODATA) --routines --no-create-info --skip-triggers $(DATABASE) | grep -v -e '^/\*\![0-9]* SET ' > $@
	@cat sql/_footer.sql >> $@

dump/tables.sql: .FORCE
	@mkdir -p dump
	@$(MYSQLDUMP_NODATA) --skip-triggers $(DATABASE) > $@
	@cat sql/_footer.sql >> $@

backup:
	 @BACKUP_FILE=./backup/$(DATABASE)-`date '+%Y-%m-%d-%X'`.sql; \
		 echo "Dumping database into $$BACKUP_FILE"; \
		 $(MYSQLDUMP) --databases $(DATABASE) > $$BACKUP_FILE && \
		 gzip  $$BACKUP_FILE

install:  .deleter
	@DATABASE=mysql  exec/install_npii.sh "$(MYSQL) mysql"

uninstall::	clean realclean

policy_service:	.deleter
	@echo "call npii.npii_init('policy_service');" | $(MYSQL) npii
	@echo "call npii.npii_init('policy_service');" | $(MYSQL) npii | $(MYSQL) $@

quote_service:	.deleter
	@echo "call npii.npii_init('quote_service');" | $(MYSQL) npii
	@echo "call npii.npii_init('quote_service');" | $(MYSQL) npii | $(MYSQL) $@

clean:
	@echo "call npii.npii_drop_all_triggers('policy_service');" | $(MYSQL) npii 
	@echo "call npii.npii_drop_all_triggers('policy_service');" | $(MYSQL) npii  | $(MYSQL) policy_service
	@echo "call npii.npii_drop_all_triggers('quote_service');" | $(MYSQL) npii 
	@echo "call npii.npii_drop_all_triggers('quote_service');" | $(MYSQL) npii  | $(MYSQL) quote_service

realclean:
	@echo "call npii.npii_drop('policy_service','policy_service_pii');" | $(MYSQL) npii 
	@echo "call npii.npii_drop('policy_service','policy_service_pii');" | $(MYSQL) npii | $(MYSQL) policy_service
	@echo "call npii.npii_drop('quote_service','quote_service_pii');" | $(MYSQL) npii 
	@echo "call npii.npii_drop('quote_service','quote_service_pii');" | $(MYSQL) npii | $(MYSQL) quote_service
	-@echo "drop database if exists npii;" | $(MYSQL) mysql
	@echo "npii database dropped."

config:
	@$(MYSQL) < sql/npii.sql

edit:	editpii
editpii: .deleter
	@exec/pii2file.sh "$(MYSQL)"
	@vim pii.csv
	@echo "importing pii.csv into database."
	@tr -d '"' < pii.csv | exec/file2pii.awk | $(MYSQL) npii 

getpii:
	@exec/pii2file.sh "$(MYSQL)"

putpii:
	@echo "importing pii.csv into database."
	@tr -d '"' < pii.csv | exec/file2pii.awk | $(MYSQL) npii 
status: check
check: .deleter
	@exec/check.sh "$(MYSQL)"

help:
	@exec/npii_help.sh

RED=\033[1;31m
GREEN=\033[1;32m
YELLOW=\033[1;33m
BLUE=\033[1;34m
PURPLE=\033[1;35m
CYAN=\033[1;36m
GREY=\033[1;37m
NORMAL=\033[0;38m
LIGHTRED=\033[1;31m
LIGHTGREEN=\033[1;32m
LIGHTYELLOW=\033[1;33m
LIGHTBLUE=\033[1;34m
LIGHTPURPLE=\033[1;35m
LIGHTCYAN=\033[1;36m
LIGHTGREY=\033[1;37m
BLINK=\033[5m
NOBLINK=\033[25m
# vim: syntax=off
