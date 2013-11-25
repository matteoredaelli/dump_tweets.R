#!/usr/bin/env Rscript

##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation, either version 3 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program.  If not, see <http://www.gnu.org/licenses/>.

##################################################################
## file history
##################################################################
## 2013-06-24: matteo redaelli: first release
## 2013-11-25: matteo redaelli: switching to mysql
##

##################################################################
## TODO
##################################################################
## 1) managing options since,until, lang
##
##

library(twitteR)
library(RMySQL)
library(logging)

## ############################################
## searchOne
## ############################################
searchOne <- function(id, q, sinceID) {
    logwarn(sprintf("Searching for q=%s, sinceID=%s", q, sinceID))
    tweets <- searchTwitter(q, n=1500, sinceID=sinceID)

    if (length(tweets) == 0) {
        logwarn("No tweets found!!")
    } else {
        tweets_df = twListToDF(tweets)
        logwarn(sprintf("Found %d tweets", nrow(tweets_df)))
        
        maxID <- max(tweets_df$id)
        logwarn(sprintf("maxID=%s", maxID))

        logwarn("saving data to tweet table...")
        dbWriteTable(con, "search_tweets", tweets_df, row.names=FALSE, append=TRUE)

        logwarn("saving data to search_results table...")
        results <- data.frame(search_for_id=id, tweet_id=tweets_df$id)
        dbWriteTable(con, "search_results", results, row.names=FALSE, append=TRUE)
        
        logwarn("updating sinceid in search_for table...")
        sql <- sprintf("update search_for set sinceid=%s where id='%s'", maxID, id) 
        dbSendQuery(con, sql)
    }
}

## ############################################
## searchFor
## ############################################
searchFor <- function(sleep=5) {
    logwarn("Connecting to twitter...")
    setup_twitter_oauth(
        consumer_key = 'm3GtR24P1biGReMyRdffg',
        consumer_secret = 'zbLnjPFSA8reqhDgpOEEc6JlvE25nSOBRSSzyXZY',
        access_token = "162665531-9qnOlxB7Ol4dxVlp0CAKjSi46khkThSbLXrYK1q3",
        access_secret = "L8OVVvHlL20IxJF9j4tgYiSBurcKlZ0384Ki4vvBM", 
        credentials_file=NULL
        )
    
    logwarn("Starting searches...")
    search.for <- dbGetQuery(con, "select * from search_for where enabled=1")

    for (c in 1:nrow(search.for)) {
        record <- search.for[c,]
        logwarn(sprintf("ID=%s, q=%s, SINCEID=%s", record$id, record$q, record$sinceid))
        try(searchOne(record$id, record$q, sinceID=record$sinceid))
        loginfo("Sleeping some seconds before a new twitter search")
        Sys.sleep(sleep)
    }
}

basicConfig()

## ############################################
## loading options
## ############################################

source("config.R")

con <- dbConnect(MySQL(),
                 db=my.config$db,
                 user=my.config$user,
                 pass=my.config$pass,
                 host=my.config$host)
searchFor(my.config$sleep.dump)
dbDisconnect(con)
