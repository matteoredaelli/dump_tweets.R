DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customers` (
  `screenName` varchar(30),
  `enabled` BOOL DEFAULT 1, 
  `search_limit` tinyint(2) DEFAULT 1,
  `timeline_limit` tinyint(2) DEFAULT 1,
  `ts` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (screenName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `customer_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer_requests` (
  `search_id` varchar(30),
  `enabled` BOOL DEFAULT 1, 
  `sinceid` varchar(30) NOT NULL DEFAULT 1,
  `ts` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (search_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

