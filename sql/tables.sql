--  Julian Carlisle   Mon Apr 15 22:04:26 PDT 2019
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `pii`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pii` (
  `table_schema` varchar(32) CHARACTER SET latin1 NOT NULL,
  `table_name` varchar(32) CHARACTER SET latin1 NOT NULL,
  `column_name` varchar(32) CHARACTER SET latin1 NOT NULL,
  primary key (table_schema,table_name,column_name)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `pii2`;
/*!50001 DROP VIEW IF EXISTS `pii2`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `pii2` AS SELECT 
 1 AS `TABLE_CATALOG`,
 1 AS `TABLE_SCHEMA`,
 1 AS `TABLE_NAME`,
 1 AS `COLUMN_NAME`,
 1 AS `TABLE_TYPE`,
 1 AS `ENGINE`,
 1 AS `VERSION`,
 1 AS `ROW_FORMAT`,
 1 AS `TABLE_ROWS`,
 1 AS `AVG_ROW_LENGTH`,
 1 AS `DATA_LENGTH`,
 1 AS `MAX_DATA_LENGTH`,
 1 AS `INDEX_LENGTH`,
 1 AS `DATA_FREE`,
 1 AS `AUTO_INCREMENT`,
 1 AS `CREATE_TIME`,
 1 AS `UPDATE_TIME`,
 1 AS `CHECK_TIME`,
 1 AS `TABLE_COLLATION`,
 1 AS `CHECKSUM`,
 1 AS `CREATE_OPTIONS`,
 1 AS `TABLE_COMMENT`*/;
SET character_set_client = @saved_cs_client;
/*!50001 DROP VIEW IF EXISTS `pii2`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=current_user SQL SECURITY DEFINER */
/*!50001 VIEW `pii2` AS select `t`.`TABLE_CATALOG` AS `TABLE_CATALOG`,`t`.`TABLE_SCHEMA` AS `TABLE_SCHEMA`,`t`.`TABLE_NAME` AS `TABLE_NAME`,`p`.`column_name` AS `COLUMN_NAME`,`t`.`TABLE_TYPE` AS `TABLE_TYPE`,`t`.`ENGINE` AS `ENGINE`,`t`.`VERSION` AS `VERSION`,`t`.`ROW_FORMAT` AS `ROW_FORMAT`,`t`.`TABLE_ROWS` AS `TABLE_ROWS`,`t`.`AVG_ROW_LENGTH` AS `AVG_ROW_LENGTH`,`t`.`DATA_LENGTH` AS `DATA_LENGTH`,`t`.`MAX_DATA_LENGTH` AS `MAX_DATA_LENGTH`,`t`.`INDEX_LENGTH` AS `INDEX_LENGTH`,`t`.`DATA_FREE` AS `DATA_FREE`,`t`.`AUTO_INCREMENT` AS `AUTO_INCREMENT`,`t`.`CREATE_TIME` AS `CREATE_TIME`,`t`.`UPDATE_TIME` AS `UPDATE_TIME`,`t`.`CHECK_TIME` AS `CHECK_TIME`,`t`.`TABLE_COLLATION` AS `TABLE_COLLATION`,`t`.`CHECKSUM` AS `CHECKSUM`,`t`.`CREATE_OPTIONS` AS `CREATE_OPTIONS`,`t`.`TABLE_COMMENT` AS `TABLE_COMMENT` from (`information_schema`.`tables` `t` join `npii`.`pii` `p`) where ((`t`.`TABLE_NAME` = convert(`p`.`table_name` using utf8)) and (`t`.`TABLE_SCHEMA` = convert(`p`.`table_schema` using utf8))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;


/* _footer.sql */
-- vim: fdm=marker fdl=0 fdc=0 fmr=DELIMITER\ ;;,DELIMITER\ \; foldtext=getline(v\:foldstart\+1)

