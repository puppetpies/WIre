--
--  WIre schema for MySQL
--

CREATE DATABASE wire;

GRANT INSERT, SELECT ON  wire.* TO 'wire'@'localhost' IDENTIFIED BY 'changeme';

USE wire;

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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `tcppacket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tcppacket` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recv_date` date DEFAULT NULL,
  `tcp_data` blob,
  `tcp_data_len` int(10) DEFAULT NULL,
  `tcp_dport` int(5) DEFAULT NULL,
  `tcp_ack` enum('Y','N') DEFAULT NULL,
  `tcp_fin` enum('Y','N') DEFAULT NULL,
  `tcp_syn` enum('Y','N') DEFAULT NULL,
  `tcp_rst` enum('Y','N') DEFAULT NULL,
  `tcp_psh` enum('Y','N') DEFAULT NULL,
  `tcp_urg` enum('Y','N') DEFAULT NULL,
  `tcp_off` int(10) DEFAULT NULL,
  `tcp_hlen` int(10) DEFAULT NULL,
  `tcp_seq` bigint(10) DEFAULT NULL,
  `tcp_sum` char(10) DEFAULT NULL,
  `tcp_sport` int(5) DEFAULT NULL,
  `tcp_urp` char(10) DEFAULT NULL,
  `tcp_win` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=INNODB DEFAULT CHARSET=latin1;
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
  PRIMARY KEY (`id`)
) ENGINE=INNODB DEFAULT CHARSET=latin1;
