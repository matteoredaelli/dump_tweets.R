# dump_tweets.R

dump_tweets.R is a tool for searching tweets and (recursively) crawl users from twitter. Data are then saved to a MySQL database and can finally be exported to .RData files



VERSION

0.4-SNASPHOT - january 2014


## SPONSORS

dump_tweets.R is sponsorized by Associazione Rospo (http://associazionerospo.org/

## INSTALLATION

1) you have to register an application at  Twitter API 

2) install a MySQL / Maria Database

3) copy config-sample.R to config.R and update it with your settings

4) use the file setup_db.sql to create a new mysql database and needed tables

  example: (if you use linux) mysql -u root < setup_db.sql

5) install R 

6) install R packages

  install.packages(c("devtools", "tm", "ggplot2", "stringr", "logging", "reshape2", "FactoMineR", "igraph", "wordcloud", "RColorBrewer", "textcat", "getopt", "RMySQL", "RCurl"))

  library(devtools)

  install_github("TextWiller", "livioivil")

  install_github("httr")

  install_github("twitteR", username="geoffjentry")

  install_github("twitteRutils", username="matteoredaelli")

## USAGE

### Searching tweets

Rscript search.R -h

Insert your favourites/recurrent searches in search-for table and then run

Rscript search.R

Rscript search.R -q "opensource OR #opensource"


### Retriving users (info and timelines)

Rscript users.R -h

Insert your favourites/recurrent users in bot_users table and then run

Rscript users.R

Lookup users from redis queue

Rscript users.R -L 

get timelines for users from redis queue

Rscript users.R -T

search hashtags from redis queue

Rscript hashtags.R -h

### Dump database to Rdata files

Rscript  dump_db.R

Regards

matteo DOT redaelli AT gmail DOT com



