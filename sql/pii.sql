--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
drop table if exists npii.pii;
create table `npii`.`pii` (
  `table_schema` varchar(32) CHARACTER SET latin1 NOT NULL,
  `table_name` varchar(32) CHARACTER SET latin1 NOT NULL,
  `column_name` varchar(32) CHARACTER SET latin1 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- The default contents of the pii table is as follows.  Check
-- with Deepak before adding or removing from this table.

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

-- A view called pii2 is used by the npii routines to perform schema 
-- manipulations.  The definition of this view is:

create or replace view `npii`.`pii2` AS select
    `t`.`TABLE_CATALOG` AS `TABLE_CATALOG`,
    `t`.`TABLE_SCHEMA` AS `TABLE_SCHEMA`,
    `t`.`TABLE_NAME` AS `TABLE_NAME`,
    `p`.`COLUMN_NAME` AS `COLUMN_NAME`,
    `t`.`TABLE_TYPE` AS `TABLE_TYPE`,
    `t`.`ENGINE` AS `ENGINE`,
    `t`.`VERSION` AS `VERSION`,
    `t`.`ROW_FORMAT` AS `ROW_FORMAT`,
    `t`.`TABLE_ROWS` AS `TABLE_ROWS`,
    `t`.`AVG_ROW_LENGTH` AS `AVG_ROW_LENGTH`,
    `t`.`DATA_LENGTH` AS `DATA_LENGTH`,
    `t`.`MAX_DATA_LENGTH` AS `MAX_DATA_LENGTH`,
    `t`.`INDEX_LENGTH` AS `INDEX_LENGTH`,
    `t`.`DATA_FREE` AS `DATA_FREE`,
    `t`.`AUTO_INCREMENT` AS `AUTO_INCREMENT`,
    `t`.`CREATE_TIME` AS `CREATE_TIME`,
    `t`.`UPDATE_TIME` AS `UPDATE_TIME`,
    `t`.`CHECK_TIME` AS `CHECK_TIME`,
    `t`.`TABLE_COLLATION` AS `TABLE_COLLATION`,
    `t`.`CHECKSUM` AS `CHECKSUM`,
    `t`.`CREATE_OPTIONS` AS `CREATE_OPTIONS`,
    `t`.`TABLE_COMMENT` AS `TABLE_COMMENT`
from
    (`information_schema`.`tables` `t`
join `npii`.`pii` `p`)
where
    ((`t`.`TABLE_NAME` = convert(`p`.`table_name`
	using utf8))
    and (`t`.`TABLE_SCHEMA` = convert(`p`.`table_schema`
	using utf8)));
