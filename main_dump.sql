/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: main
-- ------------------------------------------------------
-- Server version	10.11.14-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `jf_business_employees`
--

DROP TABLE IF EXISTS `jf_business_employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `jf_business_employees` (
  `employee_id` int(11) NOT NULL AUTO_INCREMENT,
  `sku` varchar(50) NOT NULL,
  `employee_number` int(11) NOT NULL,
  `role` enum('SALES','PRODUCTION','DISTRIBUTION','FINANCE') DEFAULT 'SALES',
  `allocated_amount` decimal(10,2) DEFAULT NULL,
  `assignment_date` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`employee_id`),
  KEY `idx_sku_role` (`sku`,`role`),
  CONSTRAINT `jf_business_employees_ibfk_1` FOREIGN KEY (`sku`) REFERENCES `jf_enterprise_products` (`sku`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jf_business_employees`
--

LOCK TABLES `jf_business_employees` WRITE;
/*!40000 ALTER TABLE `jf_business_employees` DISABLE KEYS */;
INSERT INTO `jf_business_employees` VALUES
(1,'SKU:666-666',1,'SALES',9583.33,'2025-10-31 23:18:44'),
(2,'SKU:666-666',2,'SALES',9583.33,'2025-10-31 23:18:44'),
(3,'SKU:666-666',3,'SALES',9583.33,'2025-10-31 23:18:44'),
(4,'SKU:666-666',4,'PRODUCTION',9583.33,'2025-10-31 23:18:44'),
(5,'SKU:666-666',5,'PRODUCTION',9583.33,'2025-10-31 23:18:44'),
(6,'SKU:666-666',6,'DISTRIBUTION',9583.33,'2025-10-31 23:18:44'),
(7,'SKU:333-333',1,'SALES',9583.33,'2025-10-31 23:18:44'),
(8,'SKU:333-333',2,'SALES',9583.33,'2025-10-31 23:18:44'),
(9,'SKU:333-333',3,'SALES',9583.33,'2025-10-31 23:18:44'),
(10,'SKU:333-333',4,'SALES',9583.33,'2025-10-31 23:18:44'),
(11,'SKU:333-333',5,'PRODUCTION',9583.33,'2025-10-31 23:18:44'),
(12,'SKU:333-333',6,'PRODUCTION',9583.33,'2025-10-31 23:18:44'),
(13,'SKU:333-333',7,'PRODUCTION',9583.33,'2025-10-31 23:18:44'),
(14,'SKU:333-333',8,'DISTRIBUTION',9583.33,'2025-10-31 23:18:44'),
(15,'SKU:333-333',9,'DISTRIBUTION',9583.33,'2025-10-31 23:18:44'),
(16,'SKU:999-999',1,'SALES',9583.33,'2025-10-31 23:18:44'),
(17,'SKU:999-999',2,'SALES',9583.33,'2025-10-31 23:18:44'),
(18,'SKU:999-999',3,'PRODUCTION',9583.33,'2025-10-31 23:18:44'),
(19,'SKU:222-222',1,'SALES',9583.33,'2025-10-31 23:18:44'),
(20,'SKU:222-222',2,'SALES',9583.33,'2025-10-31 23:18:44'),
(21,'SKU:222-222',3,'SALES',9583.33,'2025-10-31 23:18:44'),
(22,'SKU:222-222',4,'SALES',9583.33,'2025-10-31 23:18:44'),
(23,'SKU:222-222',5,'SALES',9583.33,'2025-10-31 23:18:44'),
(24,'SKU:222-222',6,'PRODUCTION',9583.33,'2025-10-31 23:18:44'),
(25,'SKU:222-222',7,'PRODUCTION',9583.33,'2025-10-31 23:18:44'),
(26,'SKU:222-222',8,'PRODUCTION',9583.33,'2025-10-31 23:18:44'),
(27,'SKU:222-222',9,'PRODUCTION',9583.33,'2025-10-31 23:18:44'),
(28,'SKU:222-222',10,'DISTRIBUTION',9583.33,'2025-10-31 23:18:44'),
(29,'SKU:222-222',11,'DISTRIBUTION',9583.33,'2025-10-31 23:18:44'),
(30,'SKU:222-222',12,'FINANCE',9583.33,'2025-10-31 23:18:44');
/*!40000 ALTER TABLE `jf_business_employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jf_business_telephone_network`
--

DROP TABLE IF EXISTS `jf_business_telephone_network`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `jf_business_telephone_network` (
  `call_id` int(11) NOT NULL AUTO_INCREMENT,
  `sku` varchar(50) NOT NULL,
  `tokenized_telephone` varchar(100) NOT NULL,
  `dial_type` enum('CPU_DIALED','GPU_ACCELERATED') DEFAULT 'CPU_DIALED',
  `gpu_provider` enum('NVIDIA','AMD','INTEL') DEFAULT 'NVIDIA',
  `confirmation_status` enum('PENDING','CONFIRMED_3PARTY','FAILED') DEFAULT 'PENDING',
  `money_field_requested` decimal(12,2) DEFAULT NULL,
  `money_field_confirmed` enum('YES','NO') DEFAULT 'NO',
  `confirmed_amount` decimal(12,2) DEFAULT NULL,
  `employees_allocated` int(11) DEFAULT 0,
  `equifax_business_id` varchar(100) DEFAULT NULL,
  `call_timestamp` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`call_id`),
  KEY `sku` (`sku`),
  KEY `idx_tokenized_phone` (`tokenized_telephone`),
  KEY `idx_confirmation_status` (`confirmation_status`),
  CONSTRAINT `jf_business_telephone_network_ibfk_1` FOREIGN KEY (`sku`) REFERENCES `jf_enterprise_products` (`sku`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jf_business_telephone_network`
--

LOCK TABLES `jf_business_telephone_network` WRITE;
/*!40000 ALTER TABLE `jf_business_telephone_network` DISABLE KEYS */;
INSERT INTO `jf_business_telephone_network` VALUES
(1,'SKU:666-666','TKN_101618246293127168_SKU:666-666','GPU_ACCELERATED','NVIDIA','CONFIRMED_3PARTY',57500.00,'YES',57500.00,6,'EQUIFAX_BUSINESS_12345','2025-10-31 23:17:08'),
(2,'SKU:333-333','TKN_101618246293127169_SKU:333-333','GPU_ACCELERATED','NVIDIA','CONFIRMED_3PARTY',86250.00,'YES',86250.00,9,'EQUIFAX_BUSINESS_12346','2025-10-31 23:17:08'),
(3,'SKU:999-999','TKN_101618246293127170_SKU:999-999','GPU_ACCELERATED','NVIDIA','CONFIRMED_3PARTY',28750.00,'YES',28750.00,3,'EQUIFAX_BUSINESS_12347','2025-10-31 23:17:08'),
(4,'SKU:222-222','TKN_101618246293127171_SKU:222-222','GPU_ACCELERATED','NVIDIA','CONFIRMED_3PARTY',115000.00,'YES',115000.00,12,'EQUIFAX_BUSINESS_12348','2025-10-31 23:17:08');
/*!40000 ALTER TABLE `jf_business_telephone_network` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jf_enterprise_products`
--

DROP TABLE IF EXISTS `jf_enterprise_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `jf_enterprise_products` (
  `product_id` int(11) NOT NULL AUTO_INCREMENT,
  `sku` varchar(50) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `zendesk_classification` varchar(100) DEFAULT 'ENTERPRISE_SALES',
  `product_category` enum('HORROR_FILMS','DIGITAL_RIGHTS','MERCHANDISE','LICENSING') DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `equifax_business_rating` decimal(3,2) DEFAULT 0.00,
  `telephone_token` varchar(100) DEFAULT NULL,
  `dial_status` enum('PENDING','DIALED','CONFIRMED','COMPLETED') DEFAULT 'PENDING',
  `money_field_confirmed` enum('YES','NO') DEFAULT 'NO',
  `calculated_amount` decimal(12,2) DEFAULT NULL,
  `employee_count` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `sku` (`sku`),
  KEY `idx_sku` (`sku`),
  KEY `idx_zendesk_class` (`zendesk_classification`),
  KEY `idx_dial_status` (`dial_status`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jf_enterprise_products`
--

LOCK TABLES `jf_enterprise_products` WRITE;
/*!40000 ALTER TABLE `jf_enterprise_products` DISABLE KEYS */;
INSERT INTO `jf_enterprise_products` VALUES
(1,'SKU:666-666','MONEY_IN_THE_BAG_HORROR_FILM','REOPENED_ZENDESK','HORROR_FILMS',50000.00,0.00,'TKN_101618246293127168_SKU:666-666','CONFIRMED','YES',57500.00,6,'2025-10-31 23:17:08','2025-10-31 23:18:44'),
(2,'SKU:333-333','ADULT_PSYCHOLOGICAL_THRILLER','REOPENED_ZENDESK','HORROR_FILMS',75000.00,0.00,'TKN_101618246293127169_SKU:333-333','CONFIRMED','YES',86250.00,9,'2025-10-31 23:17:08','2025-10-31 23:18:44'),
(3,'SKU:999-999','DIGITAL_STREAMING_RIGHTS','REOPENED_ZENDESK','DIGITAL_RIGHTS',25000.00,0.00,'TKN_101618246293127170_SKU:999-999','CONFIRMED','YES',28750.00,3,'2025-10-31 23:17:08','2025-10-31 23:18:44'),
(4,'SKU:222-222','INTERNATIONAL_DISTRIBUTION','REOPENED_ZENDESK','LICENSING',100000.00,0.00,'TKN_101618246293127171_SKU:222-222','CONFIRMED','YES',115000.00,12,'2025-10-31 23:17:08','2025-10-31 23:18:44');
/*!40000 ALTER TABLE `jf_enterprise_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jf_equifax_integration_log`
--

DROP TABLE IF EXISTS `jf_equifax_integration_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `jf_equifax_integration_log` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `sku` varchar(50) NOT NULL,
  `action_type` varchar(100) NOT NULL,
  `amount` decimal(12,2) DEFAULT NULL,
  `employees_involved` int(11) DEFAULT NULL,
  `api_endpoint` varchar(500) DEFAULT 'https://equifax.com/enterprise/business',
  `log_timestamp` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`log_id`),
  KEY `idx_sku_action` (`sku`,`action_type`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jf_equifax_integration_log`
--

LOCK TABLES `jf_equifax_integration_log` WRITE;
/*!40000 ALTER TABLE `jf_equifax_integration_log` DISABLE KEYS */;
INSERT INTO `jf_equifax_integration_log` VALUES
(1,'SKU:666-666','AUTO_DIAL_INITIATED',57500.00,6,'https://equifax.com/enterprise/business','2025-10-31 23:17:08'),
(2,'SKU:333-333','AUTO_DIAL_INITIATED',86250.00,9,'https://equifax.com/enterprise/business','2025-10-31 23:17:08'),
(3,'SKU:999-999','AUTO_DIAL_INITIATED',28750.00,3,'https://equifax.com/enterprise/business','2025-10-31 23:17:08'),
(4,'SKU:222-222','AUTO_DIAL_INITIATED',115000.00,12,'https://equifax.com/enterprise/business','2025-10-31 23:17:08'),
(5,'SKU:666-666','TELEPHONE_CONFIRMED',57500.00,6,'https://equifax.com/enterprise/business','2025-10-31 23:18:44'),
(6,'SKU:666-666','EMPLOYEES_ARRANGED',57500.00,6,'https://equifax.com/enterprise/business','2025-10-31 23:18:44'),
(7,'SKU:333-333','TELEPHONE_CONFIRMED',86250.00,9,'https://equifax.com/enterprise/business','2025-10-31 23:18:44'),
(8,'SKU:333-333','EMPLOYEES_ARRANGED',86250.00,9,'https://equifax.com/enterprise/business','2025-10-31 23:18:44'),
(9,'SKU:999-999','TELEPHONE_CONFIRMED',28750.00,3,'https://equifax.com/enterprise/business','2025-10-31 23:18:44'),
(10,'SKU:999-999','EMPLOYEES_ARRANGED',28750.00,3,'https://equifax.com/enterprise/business','2025-10-31 23:18:44'),
(11,'SKU:222-222','TELEPHONE_CONFIRMED',115000.00,12,'https://equifax.com/enterprise/business','2025-10-31 23:18:44'),
(12,'SKU:222-222','EMPLOYEES_ARRANGED',115000.00,12,'https://equifax.com/enterprise/business','2025-10-31 23:18:44');
/*!40000 ALTER TABLE `jf_equifax_integration_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `jf_sales_pipeline_status`
--

DROP TABLE IF EXISTS `jf_sales_pipeline_status`;
/*!50001 DROP VIEW IF EXISTS `jf_sales_pipeline_status`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `jf_sales_pipeline_status` AS SELECT
 1 AS `sku`,
  1 AS `product_name`,
  1 AS `zendesk_classification`,
  1 AS `price`,
  1 AS `dial_status`,
  1 AS `tokenized_telephone`,
  1 AS `confirmation_status`,
  1 AS `money_field_confirmed`,
  1 AS `confirmed_amount`,
  1 AS `employee_count`,
  1 AS `calculated_amount` */;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `jf_sales_pipeline_status`
--

/*!50001 DROP VIEW IF EXISTS `jf_sales_pipeline_status`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb3 */;
/*!50001 SET character_set_results     = utf8mb3 */;
/*!50001 SET collation_connection      = utf8mb3_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `jf_sales_pipeline_status` AS select `p`.`sku` AS `sku`,`p`.`product_name` AS `product_name`,`p`.`zendesk_classification` AS `zendesk_classification`,`p`.`price` AS `price`,`p`.`dial_status` AS `dial_status`,`t`.`tokenized_telephone` AS `tokenized_telephone`,`t`.`confirmation_status` AS `confirmation_status`,`t`.`money_field_confirmed` AS `money_field_confirmed`,`t`.`confirmed_amount` AS `confirmed_amount`,`p`.`employee_count` AS `employee_count`,`p`.`calculated_amount` AS `calculated_amount` from (`jf_enterprise_products` `p` left join `jf_business_telephone_network` `t` on(`p`.`sku` = `t`.`sku`)) where `p`.`zendesk_classification` = 'REOPENED_ZENDESK' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-31 23:23:09
