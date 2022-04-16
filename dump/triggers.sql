/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `policy_service` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `policy_service`;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`mysqlprod`@`%`*/ /*!50003 trigger `npii_insert_driver` after insert on `driver` for each row begin insert into `policy_service_pii`.`driver` set 

`policy_version_id` = NEW.`policy_version_id`, `driver_coverage_factor_id` = NEW.`driver_coverage_factor_id`, `active` = NEW.`active`, `age` = NEW.`age`, `age_licensed` = NEW.`age_licensed`, `city` = NEW.`city`, `created_by` = NEW.`created_by`, `created_date` = NEW.`created_date`, `dl_number` = md5(NEW.`dl_number`), `dl_state` = NEW.`dl_state`, `dl_status` = NEW.`dl_status`, `dob` = md5(NEW.`dob`), `driver_type` = NEW.`driver_type`, `education_id` = NEW.`education_id`, `end_date` = NEW.`end_date`, `first_name` = NEW.`first_name`, `gender` = NEW.`gender`, `home_owner` = NEW.`home_owner`, `household_member_id` = NEW.`household_member_id`, `last_name` = md5(NEW.`last_name`), `marital_status_id` = NEW.`marital_status_id`, `months_since_birthday` = NEW.`months_since_birthday`, `person_id` = NEW.`person_id`, `phone_number` = NEW.`phone_number`, `policy_id` = NEW.`policy_id`, `quote_id` = NEW.`quote_id`, `safe_driver` = NEW.`safe_driver`, `social_security` = md5(NEW.`social_security`), `start_date` = NEW.`start_date`, `state` = NEW.`state`, `street` = md5(NEW.`street`), `survey_completed_flag` = NEW.`survey_completed_flag`, `updated_by` = NEW.`updated_by`, `updated_date` = NEW.`updated_date`, `years_licensed` = NEW.`years_licensed`, `zip_code` = NEW.`zip_code`
, 
`driver_id` = NEW.`driver_id`  

 ; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`mysqlprod`@`%`*/ /*!50003 trigger `npii_update_driver` after update on `driver` for each row begin update `policy_service_pii`.`driver` set 

`policy_version_id` = NEW.`policy_version_id`, `driver_coverage_factor_id` = NEW.`driver_coverage_factor_id`, `active` = NEW.`active`, `age` = NEW.`age`, `age_licensed` = NEW.`age_licensed`, `city` = NEW.`city`, `created_by` = NEW.`created_by`, `created_date` = NEW.`created_date`, `dl_number` = md5(NEW.`dl_number`), `dl_state` = NEW.`dl_state`, `dl_status` = NEW.`dl_status`, `dob` = md5(NEW.`dob`), `driver_type` = NEW.`driver_type`, `education_id` = NEW.`education_id`, `end_date` = NEW.`end_date`, `first_name` = NEW.`first_name`, `gender` = NEW.`gender`, `home_owner` = NEW.`home_owner`, `household_member_id` = NEW.`household_member_id`, `last_name` = md5(NEW.`last_name`), `marital_status_id` = NEW.`marital_status_id`, `months_since_birthday` = NEW.`months_since_birthday`, `person_id` = NEW.`person_id`, `phone_number` = NEW.`phone_number`, `policy_id` = NEW.`policy_id`, `quote_id` = NEW.`quote_id`, `safe_driver` = NEW.`safe_driver`, `social_security` = md5(NEW.`social_security`), `start_date` = NEW.`start_date`, `state` = NEW.`state`, `street` = md5(NEW.`street`), `survey_completed_flag` = NEW.`survey_completed_flag`, `updated_by` = NEW.`updated_by`, `updated_date` = NEW.`updated_date`, `years_licensed` = NEW.`years_licensed`, `zip_code` = NEW.`zip_code`
WHERE 
`driver_id` = OLD.`driver_id`  

 ; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`mysqlprod`@`%`*/ /*!50003 trigger `npii_delete_driver` after delete on `driver` for each row begin delete from `policy_service_pii`.`driver` 
WHERE 
`driver_id` = OLD.`driver_id`  

 LIMIT 1 ; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`mysqlprod`@`%`*/ /*!50003 trigger `npii_insert_user` after insert on `user` for each row begin insert into `policy_service_pii`.`user` set 

`active_bit` = NEW.`active_bit`, `authentication_type` = NEW.`authentication_type`, `created_by` = NEW.`created_by`, `created_date` = NEW.`created_date`, `email` = NEW.`email`, `last_login_date` = NEW.`last_login_date`, `password` = NEW.`password`, `phone_number` = NEW.`phone_number`, `retry_count` = NEW.`retry_count`, `token` = md5(NEW.`token`), `updated_by` = NEW.`updated_by`, `updated_date` = NEW.`updated_date`, `user_onboarding_state` = NEW.`user_onboarding_state`
, 
`user_id` = NEW.`user_id`  

 ; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`mysqlprod`@`%`*/ /*!50003 trigger `npii_update_user` after update on `user` for each row begin update `policy_service_pii`.`user` set 

`active_bit` = NEW.`active_bit`, `authentication_type` = NEW.`authentication_type`, `created_by` = NEW.`created_by`, `created_date` = NEW.`created_date`, `email` = NEW.`email`, `last_login_date` = NEW.`last_login_date`, `password` = NEW.`password`, `phone_number` = NEW.`phone_number`, `retry_count` = NEW.`retry_count`, `token` = md5(NEW.`token`), `updated_by` = NEW.`updated_by`, `updated_date` = NEW.`updated_date`, `user_onboarding_state` = NEW.`user_onboarding_state`
WHERE 
`user_id` = OLD.`user_id`  

 ; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`mysqlprod`@`%`*/ /*!50003 trigger `npii_delete_user` after delete on `user` for each row begin delete from `policy_service_pii`.`user` 
WHERE 
`user_id` = OLD.`user_id`  

 LIMIT 1 ; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `quote_service` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `quote_service`;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`mysqlprod`@`%`*/ /*!50003 trigger `npii_insert_driver` after insert on `driver` for each row begin insert into `quote_service_pii`.`driver` set 

`driver_coverage_factor_id` = NEW.`driver_coverage_factor_id`, `person_id` = NEW.`person_id`, `quote_id` = NEW.`quote_id`, `active` = NEW.`active`, `age` = NEW.`age`, `age_licensed` = NEW.`age_licensed`, `city` = NEW.`city`, `created_by` = NEW.`created_by`, `created_date` = NEW.`created_date`, `dl_number` = md5(NEW.`dl_number`), `dl_state` = NEW.`dl_state`, `dl_status` = NEW.`dl_status`, `dob` = md5(NEW.`dob`), `driver_type` = NEW.`driver_type`, `education_id` = NEW.`education_id`, `first_name` = NEW.`first_name`, `gender` = NEW.`gender`, `home_owner` = NEW.`home_owner`, `last_name` = md5(NEW.`last_name`), `marital_status_id` = NEW.`marital_status_id`, `months_since_birthday` = NEW.`months_since_birthday`, `phone_number` = NEW.`phone_number`, `safe_driver` = NEW.`safe_driver`, `sequence` = NEW.`sequence`, `social_security` = md5(NEW.`social_security`), `state` = NEW.`state`, `street` = md5(NEW.`street`), `updated_by` = NEW.`updated_by`, `updated_date` = NEW.`updated_date`, `years_licensed` = NEW.`years_licensed`, `zip_code` = NEW.`zip_code`
, 
`driver_id` = NEW.`driver_id`  

 ; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`mysqlprod`@`%`*/ /*!50003 trigger `npii_update_driver` after update on `driver` for each row begin update `quote_service_pii`.`driver` set 

`driver_coverage_factor_id` = NEW.`driver_coverage_factor_id`, `person_id` = NEW.`person_id`, `quote_id` = NEW.`quote_id`, `active` = NEW.`active`, `age` = NEW.`age`, `age_licensed` = NEW.`age_licensed`, `city` = NEW.`city`, `created_by` = NEW.`created_by`, `created_date` = NEW.`created_date`, `dl_number` = md5(NEW.`dl_number`), `dl_state` = NEW.`dl_state`, `dl_status` = NEW.`dl_status`, `dob` = md5(NEW.`dob`), `driver_type` = NEW.`driver_type`, `education_id` = NEW.`education_id`, `first_name` = NEW.`first_name`, `gender` = NEW.`gender`, `home_owner` = NEW.`home_owner`, `last_name` = md5(NEW.`last_name`), `marital_status_id` = NEW.`marital_status_id`, `months_since_birthday` = NEW.`months_since_birthday`, `phone_number` = NEW.`phone_number`, `safe_driver` = NEW.`safe_driver`, `sequence` = NEW.`sequence`, `social_security` = md5(NEW.`social_security`), `state` = NEW.`state`, `street` = md5(NEW.`street`), `updated_by` = NEW.`updated_by`, `updated_date` = NEW.`updated_date`, `years_licensed` = NEW.`years_licensed`, `zip_code` = NEW.`zip_code`
WHERE 
`driver_id` = OLD.`driver_id`  

 ; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`mysqlprod`@`%`*/ /*!50003 trigger `npii_delete_driver` after delete on `driver` for each row begin delete from `quote_service_pii`.`driver` 
WHERE 
`driver_id` = OLD.`driver_id`  

 LIMIT 1 ; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`mysqlprod`@`%`*/ /*!50003 trigger `npii_insert_policyone_payment_token` after insert on `policyone_payment_token` for each row begin insert into `quote_service_pii`.`policyone_payment_token` set 

`active` = NEW.`active`, `card_number` = NEW.`card_number`, `card_type` = NEW.`card_type`, `created_by` = NEW.`created_by`, `created_date` = NEW.`created_date`, `driver_id` = NEW.`driver_id`, `expiration_month` = NEW.`expiration_month`, `expiration_year` = NEW.`expiration_year`, `card_holder_address` = NEW.`card_holder_address`, `card_holder_name` = md5(NEW.`card_holder_name`), `card_holder_zip` = NEW.`card_holder_zip`, `last_four_digits` = NEW.`last_four_digits`, `payment_method` = NEW.`payment_method`, `person_id` = NEW.`person_id`, `quote_id` = NEW.`quote_id`, `time_zone` = NEW.`time_zone`, `token` = md5(NEW.`token`), `token_creation_time` = NEW.`token_creation_time`, `updated_by` = NEW.`updated_by`, `updated_date` = NEW.`updated_date`, `validation_value` = NEW.`validation_value`
, 
`payment_token_id` = NEW.`payment_token_id`  

 ; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`mysqlprod`@`%`*/ /*!50003 trigger `npii_update_policyone_payment_token` after update on `policyone_payment_token` for each row begin update `quote_service_pii`.`policyone_payment_token` set 

`active` = NEW.`active`, `card_number` = NEW.`card_number`, `card_type` = NEW.`card_type`, `created_by` = NEW.`created_by`, `created_date` = NEW.`created_date`, `driver_id` = NEW.`driver_id`, `expiration_month` = NEW.`expiration_month`, `expiration_year` = NEW.`expiration_year`, `card_holder_address` = NEW.`card_holder_address`, `card_holder_name` = md5(NEW.`card_holder_name`), `card_holder_zip` = NEW.`card_holder_zip`, `last_four_digits` = NEW.`last_four_digits`, `payment_method` = NEW.`payment_method`, `person_id` = NEW.`person_id`, `quote_id` = NEW.`quote_id`, `time_zone` = NEW.`time_zone`, `token` = md5(NEW.`token`), `token_creation_time` = NEW.`token_creation_time`, `updated_by` = NEW.`updated_by`, `updated_date` = NEW.`updated_date`, `validation_value` = NEW.`validation_value`
WHERE 
`payment_token_id` = OLD.`payment_token_id`  

 ; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`mysqlprod`@`%`*/ /*!50003 trigger `npii_delete_policyone_payment_token` after delete on `policyone_payment_token` for each row begin delete from `quote_service_pii`.`policyone_payment_token` 
WHERE 
`payment_token_id` = OLD.`payment_token_id`  

 LIMIT 1 ; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;


/* _footer.sql */
-- vim: fdm=marker fdl=0 fdc=0 fmr=delimiter\ ;;,delimiter\ \; foldtext=getline(v\:foldstart\+1)

