CREATE DATABASE twitter
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

use twitter;

DROP TABLE IF EXISTS search_for;
CREATE TABLE search_for (
  `id` varchar(30) not null,
  `mail` varchar(300) not null,
  `q` varchar(300) not null,
  `dump_period` varchar(10) not null default '%Y-%v',
  `sinceid` BIGINT UNSIGNED not NULL default 0,
  `enabled` BOOL DEFAULT 1,
  `ts` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   PRIMARY KEY (id)
);

insert into search_for (id, mail, q) values 
  ('bridgestone', 'matteo.redaelli@gmail.com', '#Bridgestone OR @Bridgestone'),
  ('goodyear', 'matteo.redaelli@gmail.com', '#goodyear OR @goodyear_uk'),
  ('pirelli', 'matteo.redaelli@gmail.com', '#pirelli OR @Pirelli_Media'),
  ('continental', 'matteo.redaelli@gmail.com', '#continentaltire OR @continentaltire'),
  ('michelin', 'matteo.redaelli@gmail.com', '#michelin OR @MichelinTyres')
;

DROP TABLE IF EXISTS search_results;
CREATE TABLE search_results (
  `search_for_id` varchar(30) not null,
  `tweet_id` BIGINT UNSIGNED not NULL,
   PRIMARY KEY (search_for_id, tweet_id)
);

DROP TABLE IF EXISTS search_tweets;
CREATE TABLE search_tweets (
  `text` text,
  `favorited` BOOL DEFAULT NULL,
  `favoriteCount` float DEFAULT NULL,
  `replyToSN` varchar(50),
  `created` datetime,
  `truncated` tinyint(4) DEFAULT NULL,
  `replyToSID` BIGINT UNSIGNED not NULL,
  `id` BIGINT UNSIGNED not NULL,
  `replyToUID` BIGINT UNSIGNED not NULL,
  `statusSource` text,
  `screenName` varchar(50),
  `retweetCount` float DEFAULT NULL,
  `isRetweet` BOOL DEFAULT NULL,
  `retweeted` BOOL DEFAULT NULL,
  `longitude` float,
  `latitude` float,
   PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `description` text,
  `statusesCount` BIGINT UNSIGNED DEFAULT NULL,
  `followersCount` BIGINT UNSIGNED DEFAULT NULL,
  `favoritesCount` BIGINT UNSIGNED DEFAULT NULL,
  `friendsCount` BIGINT UNSIGNED DEFAULT NULL,
  `url` varchar(200),
  `name` varchar(50),
  `created` datetime,
  `protected` BOOL DEFAULT NULL,
  `verified` BOOL DEFAULT NULL,
  `screenName` varchar(50),
  `location` varchar(200),
  `id` BIGINT UNSIGNED,
  `listedCount` double DEFAULT NULL,
  `followRequestSent` BOOL DEFAULT NULL,
  `profileImageUrl` varchar(200),
  `ts` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS bot_users;
CREATE TABLE bot_users (
  `id` varchar(30) not null,
  `mail` varchar(300) not null,
  `enabled` BOOL DEFAULT 1,
  `ts` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   PRIMARY KEY (id)
);

insert into bot_users (id, mail) values 
  ('Bridgestone', 'matteo.redaelli@gmail.com'),
  ('goodyear_uk', 'matteo.redaelli@gmail.com'),
  ('Pirelli_Media', 'matteo.redaelli@gmail.com'),
  ('continentaltire', 'matteo.redaelli@gmail.com'),
  ('MichelinTyres', 'matteo.redaelli@gmail.com')
;

DROP TABLE IF EXISTS stats_db;
CREATE TABLE stats_db (
  `day` varchar(8) not null,
  `users` int(8) not null,
  `tweets` int(8) not null,
  `searches` int(8) not null,
   PRIMARY KEY (day)
);

