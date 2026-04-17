-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: ppe_tracking
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Temporary view structure for view `current_ppe_status`
--

DROP TABLE IF EXISTS `current_ppe_status`;
/*!50001 DROP VIEW IF EXISTS `current_ppe_status`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `current_ppe_status` AS SELECT 
 1 AS `issuance_id`,
 1 AS `employee`,
 1 AS `designation`,
 1 AS `ppe_type`,
 1 AS `brand_model`,
 1 AS `issuance_date`,
 1 AS `expiry_date`,
 1 AS `source`,
 1 AS `condition_status`,
 1 AS `returned_replaced`,
 1 AS `returned_date`,
 1 AS `notes`,
 1 AS `current_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `employee_id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) NOT NULL,
  `designation` varchar(50) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1' COMMENT '1=active, 0=left company',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,'A. Polog','FM',1,'2026-04-13 15:05:52'),(2,'A. Refuerzo','FM',1,'2026-04-13 15:05:52'),(3,'E. Jamolin','FM',1,'2026-04-13 15:05:52'),(4,'G. Benson','FM',1,'2026-04-13 15:05:52'),(5,'G. Estabillo','FM',1,'2026-04-13 15:05:52'),(6,'J. Dela Cruz','FM',1,'2026-04-13 15:05:52'),(7,'J. Francisco','FM',1,'2026-04-13 15:05:52'),(8,'M. Malaki','FM',1,'2026-04-13 15:05:52'),(9,'P. Perez','SFM',1,'2026-04-13 15:05:52'),(10,'R. Lima','SFM',1,'2026-04-13 15:05:52'),(11,'S. Derecho','FM',1,'2026-04-13 15:05:52');
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `expiring_soon`
--

DROP TABLE IF EXISTS `expiring_soon`;
/*!50001 DROP VIEW IF EXISTS `expiring_soon`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `expiring_soon` AS SELECT 
 1 AS `employee`,
 1 AS `designation`,
 1 AS `ppe_type`,
 1 AS `issuance_date`,
 1 AS `expiry_date`,
 1 AS `days_remaining`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `inventory_id` int NOT NULL AUTO_INCREMENT,
  `catalog_id` int NOT NULL,
  `on_hand` int NOT NULL DEFAULT '0',
  `min_stock` int NOT NULL DEFAULT '2',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_id`),
  KEY `catalog_id` (`catalog_id`),
  CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`catalog_id`) REFERENCES `ppe_catalog` (`catalog_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (1,1,0,2,'2026-04-13 15:05:52'),(2,2,0,2,'2026-04-13 15:05:52'),(3,3,0,2,'2026-04-13 15:05:52'),(4,4,0,2,'2026-04-13 15:05:52'),(5,5,0,2,'2026-04-13 15:05:52'),(6,6,0,2,'2026-04-13 15:05:52'),(7,7,0,2,'2026-04-13 15:05:52'),(8,8,0,2,'2026-04-13 15:05:52'),(9,9,0,2,'2026-04-13 15:05:52'),(10,10,0,2,'2026-04-13 15:05:52');
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `needs_action`
--

DROP TABLE IF EXISTS `needs_action`;
/*!50001 DROP VIEW IF EXISTS `needs_action`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `needs_action` AS SELECT 
 1 AS `employee`,
 1 AS `designation`,
 1 AS `ppe_type`,
 1 AS `condition_status`,
 1 AS `issuance_date`,
 1 AS `notes`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ppe_catalog`
--

DROP TABLE IF EXISTS `ppe_catalog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ppe_catalog` (
  `catalog_id` int NOT NULL AUTO_INCREMENT,
  `ppe_type` varchar(100) NOT NULL,
  `has_expiry` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1=has expiry date',
  `expiry_months` int DEFAULT NULL COMMENT 'months from issuance to expiry. NULL if no expiry',
  PRIMARY KEY (`catalog_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ppe_catalog`
--

LOCK TABLES `ppe_catalog` WRITE;
/*!40000 ALTER TABLE `ppe_catalog` DISABLE KEYS */;
INSERT INTO `ppe_catalog` VALUES (1,'Coverall',0,NULL),(2,'Half-Mask Respirator',0,NULL),(3,'Safety Shoes',0,NULL),(4,'Working Gloves',0,NULL),(5,'Hard Hat',0,NULL),(6,'Safety Glasses',0,NULL),(7,'Gloves',0,NULL),(8,'Rain Gear',0,NULL),(9,'Cartridge',1,6),(10,'Headlamp',0,NULL);
/*!40000 ALTER TABLE `ppe_catalog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ppe_issuances`
--

DROP TABLE IF EXISTS `ppe_issuances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ppe_issuances` (
  `issuance_id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `catalog_id` int NOT NULL,
  `brand_model` varchar(100) DEFAULT NULL,
  `issuance_date` date NOT NULL,
  `expiry_date` date DEFAULT NULL COMMENT 'auto-set by trigger for items with expiry',
  `source` enum('Manual','Auto') NOT NULL DEFAULT 'Manual',
  `condition_status` enum('Good','Damaged','For Replacement','Lost','Misplaced','Expired') NOT NULL DEFAULT 'Good',
  `returned_replaced` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0=No, 1=Yes',
  `returned_date` date DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`issuance_id`),
  KEY `employee_id` (`employee_id`),
  KEY `catalog_id` (`catalog_id`),
  CONSTRAINT `ppe_issuances_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`),
  CONSTRAINT `ppe_issuances_ibfk_2` FOREIGN KEY (`catalog_id`) REFERENCES `ppe_catalog` (`catalog_id`)
) ENGINE=InnoDB AUTO_INCREMENT=240 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ppe_issuances`
--

LOCK TABLES `ppe_issuances` WRITE;
/*!40000 ALTER TABLE `ppe_issuances` DISABLE KEYS */;
INSERT INTO `ppe_issuances` VALUES (1,1,5,'Delta Plus','2025-09-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(2,1,6,'Delta Plus / Clear','2025-02-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(3,1,2,NULL,'2023-07-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(4,1,9,NULL,'2023-07-18','2024-01-18','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(5,1,9,NULL,'2024-01-13','2024-07-13','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(6,1,9,NULL,'2024-07-23','2025-01-23','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(7,1,9,NULL,'2025-03-09','2025-09-09','Manual','Lost',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(8,1,9,NULL,'2025-09-13','2026-03-13','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(9,1,3,NULL,'2023-07-01',NULL,'Manual','Damaged',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(10,1,3,'Delta Plus','2025-02-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(11,1,1,NULL,'2023-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(12,1,1,NULL,'2023-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(13,1,1,NULL,'2024-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(14,1,8,NULL,'2023-07-01',NULL,'Manual','Damaged',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(15,1,8,NULL,'2025-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(16,1,4,NULL,'2023-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(17,10,5,NULL,'2022-02-01',NULL,'Manual','Damaged',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(18,10,5,NULL,'2024-08-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(19,10,10,NULL,'2022-02-01',NULL,'Manual','Damaged',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(20,10,10,NULL,'2025-04-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(21,10,6,NULL,'2022-02-01',NULL,'Manual','Damaged',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(22,10,6,'Ultima / OTG','2022-04-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(23,10,6,'3M / Tinted','2024-02-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(24,10,6,'Delta Plus / Clear','2024-08-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(25,10,2,NULL,'2022-02-01',NULL,'Manual','Damaged',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(26,10,2,NULL,'2024-08-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(27,10,9,NULL,'2022-02-04','2022-08-04','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(28,10,9,NULL,'2022-08-01','2023-02-01','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(29,10,9,NULL,'2023-02-01','2023-08-01','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(30,10,9,NULL,'2023-08-01','2024-02-01','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(31,10,9,NULL,'2024-02-01','2024-08-01','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(32,10,9,NULL,'2024-07-01','2025-01-01','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(33,10,9,NULL,'2025-01-29','2025-07-29','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(34,10,9,NULL,'2025-07-04','2026-01-04','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(35,10,9,NULL,'2026-01-30','2026-07-30','Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(36,10,3,NULL,'2024-10-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(37,10,1,NULL,'2024-02-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(38,10,1,'Ultima','2024-08-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(39,10,1,'Red Wing / 34','2024-03-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(40,10,1,NULL,'2024-09-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(41,10,8,NULL,'2022-02-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(42,10,4,NULL,'2022-03-01',NULL,'Manual','Damaged',1,'2022-06-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(43,10,4,'Deltaplus','2025-07-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(44,9,5,NULL,'2024-03-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(45,9,10,NULL,'2021-10-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(46,9,6,NULL,'2021-10-01',NULL,'Manual','Good',1,'2022-11-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(47,9,6,'Deltaplus / Clear','2022-12-01',NULL,'Manual','Good',1,'2024-09-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(48,9,6,'3M / Tinted','2023-05-01',NULL,'Manual','Damaged',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(49,9,6,'Deltaplus','2024-09-01',NULL,'Manual','Damaged',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(50,9,6,'Deltaplus / Tinted','2025-03-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(51,9,6,'Deltaplus / Clear','2025-04-01',NULL,'Manual','For Replacement',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(52,9,2,NULL,'2021-10-01',NULL,'Manual','Good',1,'2025-12-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(53,9,2,NULL,'2025-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(54,9,9,NULL,'2021-04-01','2021-10-01','Manual','Expired',1,'2021-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(55,9,9,NULL,'2021-10-01','2022-04-01','Manual','Expired',1,'2022-04-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(56,9,9,NULL,'2022-04-01','2022-10-01','Manual','Expired',1,'2023-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(57,9,9,NULL,'2023-10-01','2024-04-01','Manual','Expired',1,'2024-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(58,9,9,NULL,'2023-11-01','2024-05-01','Manual','Expired',1,'2024-05-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(59,9,9,NULL,'2024-05-01','2024-11-01','Manual','Expired',1,'2024-11-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(60,9,9,NULL,'2024-11-01','2025-05-01','Manual','Expired',1,'2025-07-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(61,9,9,NULL,'2025-07-01','2026-01-01','Manual','Expired',1,'2026-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(62,9,9,NULL,'2026-01-01','2026-07-01','Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(63,9,3,NULL,'2021-10-01',NULL,'Manual','Good',1,'2021-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(64,9,3,NULL,'2023-05-01',NULL,'Manual','Good',1,'2023-05-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(65,9,3,NULL,'2023-10-01',NULL,'Manual','Good',0,'2023-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(66,9,1,'U SAFE / XXL','2021-11-01',NULL,'Manual','Good',1,'2022-06-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(67,9,1,'Ultima / XXL','2022-06-01',NULL,'Manual','Good',1,'2025-12-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(68,9,1,'Frontliner / XXL','2024-07-01',NULL,'Manual','Good',1,'2025-11-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(69,9,1,'Red Wing / 44','2023-10-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(70,9,1,'Ultima / XL','2024-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(71,9,1,NULL,'2025-09-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(72,9,8,NULL,'2022-02-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(73,9,4,'Deltaplus','2024-10-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(74,3,5,NULL,'2023-07-01',NULL,'Manual','Good',1,'2025-05-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(75,3,5,NULL,'2025-05-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(76,3,6,NULL,'2023-07-01',NULL,'Manual','Good',1,'2024-08-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(77,3,6,NULL,'2024-08-01',NULL,'Manual','Good',1,'2026-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(78,3,6,'Clear','2026-01-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(79,3,6,'Tinted','2026-01-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(80,3,2,NULL,'2023-07-01',NULL,'Manual','Good',1,'2024-05-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(81,3,2,NULL,'2024-05-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(82,3,9,NULL,'2023-07-01','2024-01-01','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(83,3,9,NULL,'2024-11-01','2025-05-01','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(84,3,9,NULL,'2025-05-01','2025-11-01','Manual','Expired',1,'2026-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(85,3,9,NULL,'2026-01-01','2026-07-01','Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(86,3,3,NULL,'2023-07-01',NULL,'Manual','Good',1,'2025-05-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(87,3,3,NULL,'2025-05-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(88,3,1,NULL,'2023-07-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(89,3,1,NULL,'2023-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(90,3,8,NULL,'2023-07-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(91,3,4,NULL,'2023-04-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(92,11,5,NULL,'2023-06-01',NULL,'Manual','Good',1,'2025-06-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(93,11,5,NULL,'2025-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(94,11,6,NULL,'2023-06-01',NULL,'Manual','Good',1,'2024-05-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(95,11,6,NULL,'2024-05-01',NULL,'Manual','Good',1,'2026-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(96,11,6,'Clear','2026-01-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(97,11,6,'Tinted','2026-01-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(98,11,2,NULL,'2023-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(99,11,9,NULL,'2023-06-01','2023-12-01','Manual','Expired',1,'2024-12-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(100,11,9,NULL,'2024-12-01','2025-06-01','Manual','Expired',1,'2025-06-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(101,11,9,NULL,'2025-06-01','2025-12-01','Manual','Expired',1,'2026-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(102,11,9,NULL,'2026-01-01','2026-07-01','Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(103,11,3,NULL,'2023-06-01',NULL,'Manual','Good',1,'2024-11-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(104,11,3,'Deltaplus','2024-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(105,11,1,'Fronliner','2023-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(106,11,1,'Ultima','2023-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(107,11,1,'Ultima','2024-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(108,11,8,'Deltaplus','2023-07-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(109,11,4,'Deltaplus','2023-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(110,6,5,NULL,'2021-11-01',NULL,'Manual','Good',1,'2023-02-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(111,6,5,NULL,'2023-02-01',NULL,'Manual','Good',1,'2025-06-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(112,6,5,NULL,'2025-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(113,6,6,'Clear','2023-01-01',NULL,'Manual','Good',1,'2024-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(114,6,6,'Tinted','2023-02-01',NULL,'Manual','Good',1,'2024-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(115,6,6,'Clear','2023-12-01',NULL,'Manual','Good',1,'2024-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(116,6,6,'Clear','2024-10-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(117,6,6,'Tinted','2024-10-01',NULL,'Manual','Good',1,'2025-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(118,6,6,'Tinted','2026-01-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(119,6,2,NULL,'2021-10-01',NULL,'Manual','Good',1,'2025-04-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(120,6,2,NULL,'2025-04-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(121,6,9,NULL,'2021-10-01','2022-04-01','Manual','Expired',1,'2022-04-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(122,6,9,NULL,'2022-04-01','2022-10-01','Manual','Expired',1,'2023-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(123,6,9,NULL,'2023-01-01','2023-07-01','Manual','Expired',1,'2023-07-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(124,6,9,NULL,'2023-07-01','2024-01-01','Manual','Expired',1,'2024-02-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(125,6,9,NULL,'2024-02-01','2024-08-01','Manual','Expired',1,'2025-04-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(126,6,9,NULL,'2025-04-01','2025-10-01','Manual','Expired',1,'2026-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(127,6,9,NULL,'2026-01-01','2026-07-01','Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(128,6,3,NULL,'2021-09-01',NULL,'Manual','Good',1,'2023-05-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(129,6,3,NULL,'2023-06-01',NULL,'Manual','Good',1,'2024-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(130,6,3,NULL,'2024-10-01',NULL,'Manual','Good',1,'2025-08-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(131,6,3,NULL,'2025-08-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(132,6,1,'Ultima','2021-09-01',NULL,'Manual','Good',1,'2024-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(133,6,1,'Red Wing','2023-08-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(134,6,1,'IS Safe','2024-10-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(135,6,1,'IS Safe','2024-10-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(136,6,1,'Ultima','2025-02-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(137,6,8,'Deltaplus','2023-08-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(138,6,4,'3M','2023-12-01',NULL,'Manual','For Replacement',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(139,7,5,NULL,'2023-04-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(140,7,6,'Deltaplus / Clear','2023-04-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(141,7,6,'Deltaplus / Tinted','2024-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(142,7,2,NULL,'2023-04-01',NULL,'Manual','Good',1,'2025-11-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(143,7,2,NULL,'2025-07-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(144,7,9,NULL,'2023-04-01','2023-10-01','Manual','Expired',1,'2023-09-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(145,7,9,NULL,'2023-09-01','2024-03-01','Manual','Expired',1,'2024-05-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(146,7,9,NULL,'2024-05-01','2024-11-01','Manual','Expired',1,'2024-11-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(147,7,9,NULL,'2024-11-01','2025-05-01','Manual','Expired',1,'2025-07-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(148,7,9,NULL,'2025-07-01','2026-01-01','Manual','Expired',1,'2026-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(149,7,9,NULL,'2026-01-01','2026-07-01','Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(150,7,3,NULL,'2023-04-01',NULL,'Manual','Good',1,'2023-11-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(151,7,3,NULL,'2023-11-01',NULL,'Manual','Good',1,'2025-06-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(152,7,3,'Deltaplus','2025-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(153,7,1,'Ultima','2023-04-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(154,7,1,NULL,'2023-09-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(155,7,1,'Red Wing','2024-07-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(156,7,1,NULL,'2025-09-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(157,7,8,NULL,'2025-05-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(158,7,4,NULL,'2023-07-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(159,5,5,NULL,'2023-04-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(160,5,6,'3M / Clear','2023-04-01',NULL,'Manual','Damaged',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(161,5,6,'3M / Tinted','2024-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(162,5,6,'Deltaplus / Clear','2025-01-01',NULL,'Manual','Good',1,'2025-09-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(163,5,6,'Deltaplus / Clear','2025-09-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(164,5,2,NULL,'2023-04-01',NULL,'Manual','Good',1,'2025-11-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(165,5,2,NULL,'2025-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(166,5,9,NULL,'2023-04-01','2023-10-01','Manual','Expired',1,'2023-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(167,5,9,NULL,'2023-10-01','2024-04-01','Manual','Expired',1,'2024-05-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(168,5,9,NULL,'2024-05-01','2024-11-01','Manual','Expired',1,'2024-11-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(169,5,9,NULL,'2024-11-01','2025-05-01','Manual','Expired',1,'2025-07-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(170,5,9,NULL,'2025-07-01','2026-01-01','Manual','Expired',1,'2026-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(171,5,9,NULL,'2026-01-01','2026-07-01','Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(172,5,3,'Safety Jogger','2024-04-01',NULL,'Manual','Good',1,'2024-07-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(173,5,3,'Safety Jogger','2024-07-01',NULL,'Manual','Good',1,'2025-05-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(174,5,3,'Deltaplus','2025-05-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(175,5,1,'Frontliner','2023-04-01',NULL,'Manual','Good',1,'2024-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(176,5,1,'Ultima','2023-07-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(177,5,1,'Red Wing','2024-07-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(178,5,1,NULL,'2025-09-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(179,5,8,NULL,'2023-10-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(180,5,4,NULL,'2023-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(181,4,5,'Deltaplus','2023-03-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(182,4,6,NULL,'2023-03-01',NULL,'Manual','Good',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(183,4,6,NULL,'2024-02-01',NULL,'Manual','Good',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(184,4,6,NULL,'2025-03-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(185,4,6,'Tinted','2026-01-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(186,4,2,NULL,'2023-04-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(187,4,9,NULL,'2023-04-01','2023-10-01','Manual','Expired',1,'2023-09-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(188,4,9,NULL,'2023-11-01','2024-05-01','Manual','Expired',1,'2025-03-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(189,4,9,NULL,'2025-03-01','2025-09-01','Manual','Expired',1,'2025-10-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(190,4,9,NULL,'2025-10-01','2026-04-01','Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(191,4,3,NULL,'2023-03-01',NULL,'Manual','Good',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(192,4,3,NULL,'2024-02-01',NULL,'Manual','Good',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(193,4,3,'Deltaplus','2024-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(194,4,1,'Ultima','2023-04-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(195,4,1,'Frontliner','2023-04-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(196,4,1,'Frontliner','2023-12-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(197,4,1,'Frontliner','2024-10-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(198,4,8,'Deltaplus','2023-08-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(199,4,4,NULL,'2023-04-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(200,2,5,'MSA','2025-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(201,2,6,'3M / Clear','2024-06-01',NULL,'Manual','Good',1,'2026-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(202,2,6,'Clear','2026-01-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(203,2,2,NULL,'2023-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(204,2,9,NULL,'2023-03-01','2023-09-01','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(205,2,9,NULL,'2024-06-01','2024-12-01','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(206,2,9,NULL,'2025-02-01','2025-08-01','Manual','Expired',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(207,2,9,NULL,'2025-07-01','2026-01-01','Manual','Expired',1,'2026-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(208,2,9,NULL,'2026-01-01','2026-07-01','Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(209,2,3,NULL,'2023-05-01',NULL,'Manual','Good',1,'2024-07-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(210,2,3,NULL,'2024-07-01',NULL,'Manual','Good',1,'2025-02-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(211,2,3,NULL,'2024-12-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(212,2,1,NULL,'2023-08-01',NULL,'Manual','Good',1,'2024-08-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(213,2,1,'Red Wing','2024-01-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(214,2,1,'Ultima','2024-12-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(215,2,1,'Ultima','2025-03-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(216,2,8,NULL,'2023-08-01',NULL,'Manual','For Replacement',1,'2024-09-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(217,2,4,NULL,'2024-06-01',NULL,'Manual','For Replacement',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(218,8,5,NULL,'2023-06-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(219,8,6,'Clear','2023-07-01',NULL,'Manual','Good',1,'2025-07-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(220,8,6,'Deltaplus / Tinted','2024-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(221,8,6,'Clear','2025-07-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(222,8,2,NULL,'2023-07-01',NULL,'Manual','Good',1,'2024-11-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(223,8,2,NULL,'2024-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(224,8,9,NULL,'2023-07-01','2024-01-01','Manual','Expired',1,'2023-12-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(225,8,9,NULL,'2023-12-01','2024-06-01','Manual','Expired',1,'2024-06-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(226,8,9,NULL,'2024-06-01','2024-12-01','Manual','Expired',1,'2025-02-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(227,8,9,NULL,'2025-02-01','2025-08-01','Manual','Expired',1,'2025-07-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(228,8,9,NULL,'2025-07-01','2026-01-01','Manual','Expired',1,'2026-01-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(229,8,9,NULL,'2026-01-01','2026-07-01','Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(230,8,3,'Safety Jogger','2023-06-01',NULL,'Manual','Good',1,'2024-06-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(231,8,3,'Deltaplus','2024-06-01',NULL,'Manual','Good',1,'2024-11-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(232,8,3,'Safety Jogger','2024-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(233,8,1,'Frontliner','2023-06-01',NULL,'Manual','Good',1,'2024-03-01',NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(234,8,1,'Ultima','2023-10-01',NULL,'Manual','Good',1,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(235,8,1,'Red Wing','2024-07-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(236,8,1,'Ultima','2024-10-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(237,8,1,'Ultima','2025-12-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(238,8,8,NULL,'2023-11-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52'),(239,8,4,NULL,'2025-09-01',NULL,'Manual','Good',0,NULL,NULL,'2026-04-13 15:05:52','2026-04-13 15:05:52');
/*!40000 ALTER TABLE `ppe_issuances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ppe_status_log`
--

DROP TABLE IF EXISTS `ppe_status_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ppe_status_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `issuance_id` int NOT NULL,
  `old_condition` varchar(50) DEFAULT NULL,
  `new_condition` varchar(50) DEFAULT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) DEFAULT NULL,
  `changed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `notes` text COMMENT 'reason for change',
  PRIMARY KEY (`log_id`),
  KEY `issuance_id` (`issuance_id`),
  CONSTRAINT `ppe_status_log_ibfk_1` FOREIGN KEY (`issuance_id`) REFERENCES `ppe_issuances` (`issuance_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ppe_status_log`
--

LOCK TABLES `ppe_status_log` WRITE;
/*!40000 ALTER TABLE `ppe_status_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `ppe_status_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `requests`
--

DROP TABLE IF EXISTS `requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `requests` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `catalog_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `request_date` date NOT NULL,
  `stock_status` enum('In Stock','No Stock') NOT NULL DEFAULT 'No Stock',
  `issued_date` date DEFAULT NULL,
  `issuance_id` int DEFAULT NULL COMMENT 'links to ppe_issuances when fulfilled',
  `status` enum('Pending','Ready to Issue','Issued','Waiting Stock') NOT NULL DEFAULT 'Pending',
  `notes` text,
  PRIMARY KEY (`request_id`),
  KEY `employee_id` (`employee_id`),
  KEY `catalog_id` (`catalog_id`),
  KEY `issuance_id` (`issuance_id`),
  CONSTRAINT `requests_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`),
  CONSTRAINT `requests_ibfk_2` FOREIGN KEY (`catalog_id`) REFERENCES `ppe_catalog` (`catalog_id`),
  CONSTRAINT `requests_ibfk_3` FOREIGN KEY (`issuance_id`) REFERENCES `ppe_issuances` (`issuance_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `requests`
--

LOCK TABLES `requests` WRITE;
/*!40000 ALTER TABLE `requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `current_ppe_status`
--

/*!50001 DROP VIEW IF EXISTS `current_ppe_status`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `current_ppe_status` AS select `i`.`issuance_id` AS `issuance_id`,`e`.`full_name` AS `employee`,`e`.`designation` AS `designation`,`c`.`ppe_type` AS `ppe_type`,`i`.`brand_model` AS `brand_model`,`i`.`issuance_date` AS `issuance_date`,`i`.`expiry_date` AS `expiry_date`,`i`.`source` AS `source`,`i`.`condition_status` AS `condition_status`,`i`.`returned_replaced` AS `returned_replaced`,`i`.`returned_date` AS `returned_date`,`i`.`notes` AS `notes`,(case when ((`i`.`condition_status` = 'For Replacement') and (`i`.`returned_replaced` = 1)) then 'Returned' when ((`i`.`condition_status` = 'Lost') and (`i`.`returned_replaced` = 1)) then 'Replaced' when ((`i`.`condition_status` = 'Misplaced') and (`i`.`returned_replaced` = 1)) then 'Replaced' when (`i`.`returned_replaced` = 1) then 'Returned' when (`i`.`condition_status` = 'Damaged') then 'Damaged' when (`i`.`condition_status` = 'Lost') then 'Lost - For Replacement' when (`i`.`condition_status` = 'Misplaced') then 'Misplaced - For Replacement' when (`i`.`condition_status` = 'For Replacement') then 'For Replacement' when (`i`.`condition_status` = 'Expired') then 'Expired' when (`i`.`expiry_date` is null) then 'Active' when (`i`.`expiry_date` < curdate()) then 'Expired' when ((to_days(`i`.`expiry_date`) - to_days(curdate())) <= 30) then 'Expiring Soon' else 'Active' end) AS `current_status` from ((`ppe_issuances` `i` join `employees` `e` on((`e`.`employee_id` = `i`.`employee_id`))) join `ppe_catalog` `c` on((`c`.`catalog_id` = `i`.`catalog_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `expiring_soon`
--

/*!50001 DROP VIEW IF EXISTS `expiring_soon`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `expiring_soon` AS select `e`.`full_name` AS `employee`,`e`.`designation` AS `designation`,`c`.`ppe_type` AS `ppe_type`,`i`.`issuance_date` AS `issuance_date`,`i`.`expiry_date` AS `expiry_date`,(to_days(`i`.`expiry_date`) - to_days(curdate())) AS `days_remaining` from ((`ppe_issuances` `i` join `employees` `e` on((`e`.`employee_id` = `i`.`employee_id`))) join `ppe_catalog` `c` on((`c`.`catalog_id` = `i`.`catalog_id`))) where ((`i`.`expiry_date` is not null) and (`i`.`expiry_date` >= curdate()) and ((to_days(`i`.`expiry_date`) - to_days(curdate())) <= 30) and (`i`.`returned_replaced` = 0)) order by `i`.`expiry_date` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `needs_action`
--

/*!50001 DROP VIEW IF EXISTS `needs_action`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `needs_action` AS select `e`.`full_name` AS `employee`,`e`.`designation` AS `designation`,`c`.`ppe_type` AS `ppe_type`,`i`.`condition_status` AS `condition_status`,`i`.`issuance_date` AS `issuance_date`,`i`.`notes` AS `notes` from ((`ppe_issuances` `i` join `employees` `e` on((`e`.`employee_id` = `i`.`employee_id`))) join `ppe_catalog` `c` on((`c`.`catalog_id` = `i`.`catalog_id`))) where ((`i`.`condition_status` in ('For Replacement','Damaged','Lost','Misplaced')) and (`i`.`returned_replaced` = 0)) order by `i`.`condition_status`,`e`.`full_name` */;
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

-- Dump completed on 2026-04-17 14:59:56
