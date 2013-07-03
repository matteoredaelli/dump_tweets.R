dump_tweets.R
=============

you have to create  Twitter API and then register it

> library(twitteR)
> twitCred <-   OAuthFactory$new(consumerKey="XXX",
+ consumerSecret="XXX",
+ requestURL="https://api.twitter.com/oauth/request_token",
+ accessURL="http://api.twitter.com/oauth/access_token",
+ authURL="http://api.twitter.com/oauth/authorize")
> twitCred$handshake()
> save(twitCred, file="rospoTongue.Rdata")

matteo@ubuntu:~/src/dump_tweets.R$ Rscript dump_tweets.R --help
Usage: dump_tweets.R [-[-verbose|v] [<integer>]] [-[-help|h]] [-[-add|a] <character>] [-[-db|d] <character>] [-[-records|n] <integer>] [-[-show|s]] [-[-version|V]]

matteo@ubuntu:~/src/dump_tweets$ Rscript dump_tweets.R --import search.csv 

matteo@ubuntu:~/src/dump_tweets$ Rscript dump_tweets.R --show
  row_names        uid        tag      since      until lang
1         1 opensource opensource 2000-01-01 2013-07-24 NULL

matteo@ubuntu:~/src/dump_tweets$ Rscript dump_tweets.R 
2013-06-24 23:04:08 INFO::Dump tweets for opensource
2013-06-24 23:04:08 WARNING::table options does not exist
2013-06-24 23:04:08 WARNING::sinceID=000000000000000000
2013-06-24 23:04:10 WARNING::Found 15 tweets
2013-06-24 23:04:10 WARNING::maxID=349271167829409792
2013-06-24 23:04:10 INFO::Sleeping some seconds before a new twitter search

