--
--  WIre schema for MySQL
--
-- MySQL dump 10.15  Distrib 10.0.17-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: wire
-- ------------------------------------------------------
-- Server version	10.0.17-MariaDB-log

CREATE DATABASE wire;
GRANT SELECT, INSERT, DELETE ON  wire.* TO 'wire'@'localhost' IDENTIFIED BY 'changeme';
USE wire;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ippacket`
--

DROP TABLE IF EXISTS `ippacket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ippacket` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recv_date` date DEFAULT NULL,
  `ip_df` varchar(5) DEFAULT NULL,
  `ip_dst` varchar(15) DEFAULT NULL,
  `ip_hlen` int(11) NOT NULL,
  `ip_id` int(11) NOT NULL,
  `ip_len` int(11) NOT NULL,
  `ip_mf` varchar(5) DEFAULT NULL,
  `ip_off` int(11) NOT NULL,
  `ip_proto` int(11) NOT NULL,
  `ip_src` varchar(15) DEFAULT NULL,
  `ip_sum` char(10) DEFAULT NULL,
  `ip_tos` int(11) NOT NULL,
  `ip_ttl` int(11) NOT NULL,
  `ip_ver` int(11) NOT NULL,
  `guid` char(36) DEFAULT NULL,
  `recv_time` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `guid` (`guid`)
) ENGINE=InnoDB AUTO_INCREMENT=79936 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tcppacket`
--

DROP TABLE IF EXISTS `tcppacket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tcppacket` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recv_date` date DEFAULT NULL,
  `tcp_data` blob,
  `tcp_data_len` int(10) DEFAULT NULL,
  `tcp_dport` int(5) DEFAULT NULL,
  `tcp_ack` enum('true','false') DEFAULT NULL,
  `tcp_fin` enum('true','false') DEFAULT NULL,
  `tcp_syn` enum('true','false') DEFAULT NULL,
  `tcp_rst` enum('true','false') DEFAULT NULL,
  `tcp_psh` enum('true','false') DEFAULT NULL,
  `tcp_urg` enum('true','false') DEFAULT NULL,
  `tcp_off` int(10) DEFAULT NULL,
  `tcp_hlen` int(10) DEFAULT NULL,
  `tcp_seq` bigint(10) DEFAULT NULL,
  `tcp_sum` char(10) DEFAULT NULL,
  `tcp_sport` int(5) DEFAULT NULL,
  `tcp_urp` char(10) DEFAULT NULL,
  `tcp_win` int(10) DEFAULT NULL,
  `guid` char(36) DEFAULT NULL,
  `recv_time` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `guid` (`guid`)
) ENGINE=InnoDB AUTO_INCREMENT=79936 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `udppacket`
--

DROP TABLE IF EXISTS `udppacket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `udppacket` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recv_date` date DEFAULT NULL,
  `udp_data` blob,
  `udp_dport` int(5) DEFAULT NULL,
  `udp_len` int(10) DEFAULT NULL,
  `udp_sum` char(10) DEFAULT NULL,
  `udp_sport` int(5) DEFAULT NULL,
  `guid` char(36) DEFAULT NULL,
  `recv_time` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-10-10 21:59:22
