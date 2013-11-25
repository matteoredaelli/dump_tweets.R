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
  ('Bridgestone', 'matteo.redaelli@gmail.com', '#Bridgestone OR @Bridgestone'),
  ('goodyear', 'matteo.redaelli@gmail.com', '#goodyear OR @goodyear_uk'),
  ('pirelli', 'matteo.redaelli@gmail.com', '#pirelli OR @Pirelli_Media'),
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
