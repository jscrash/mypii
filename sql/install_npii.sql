--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
-- Install procedures into MySQL schema

-- set charset
/*!40101 SET NAMES utf8 */;
use mysql;
create database if not exists npii;
grant alter, alter routine, create,create routine, create view,
delete,drop,execute,select,trigger,update on *.* to npii;
START TRANSACTION;
SELECT '-- INFO: Installing procedures' AS '-- INFO:';
use npii;
source npii.sql;
source tables.sql;
insert into `npii`.`pii` (table_schema,table_name,column_name) VALUES 
('policy_service','driver','last_name')
,('policy_service','driver','dl_number')
,('policy_service','driver','dob')
,('policy_service','driver','social_security')
,('policy_service','driver','street')
,('policy_service','user','token')
,('quote_service','driver','last_name')
,('quote_service','driver','dl_number')
,('quote_service','driver','dob')
,('quote_service','driver','social_security')
,('quote_service','driver','street');

SELECT '-- INFO: DONE - procedures installed' AS '-- INFO:';

COMMIT;

-- vim: ft=sql
