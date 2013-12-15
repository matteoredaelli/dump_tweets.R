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
## 2013-11-26: matteo redaelli: first release
##

##################################################################
## TODO
##################################################################
## 
##
##

library(RMySQL)

## ############################################
## saveTweetsAndSinceID
## ############################################
saveTweetsAndSinceID <- function(id, tweets, sinceID.table, results.table=NULL) {
    if (length(tweets) == 0) {
        logwarn("No tweets found!!")
    } else if (!is.null(tweets[1]$error)) {
        logwarn(sprintf("ERROR: %s", tweets$error))
    } else {
        tweets_df = twListToDF(tweets)
        logwarn(sprintf("Found %d tweets", nrow(tweets_df)))
        
        tweets_df$text <- unlist(lapply(tweets_df$text, function(t) iconv(t, to="UTF8")))
        #tweets_df$lang <- textcat(tweets$text, ECIMCI_profiles)


        maxID <- max(tweets_df$id)
        logwarn(sprintf("maxID=%s", maxID))

        logwarn("Saving data to tweet table...")
        dbWriteTable(con, "tweets", tweets_df, row.names=FALSE, append=TRUE)

        if (!is.null(results.table)) {
            logwarn(sprintf("saving data to %s table...", results.table))
            results <- data.frame(search_for_id=id, tweet_id=tweets_df$id)
            dbWriteTable(con, results.table, results, row.names=FALSE, append=TRUE)
        }
        
        logwarn(sprintf("updating table %s...", sinceID.table))
        sql <- sprintf("update %s set sinceid=%s where id='%s'", sinceID.table, maxID, id)
        logwarn(sql)
        dbSendQuery(con, sql)
    }
}

## ############################################
## loading options
## ############################################
logwarn(sprintf("Connecting to database=%s, host=%s with user=%s",
                my.config$db, my.config$host, my.config$user))

con <- dbConnect(MySQL(),
                 db=my.config$db,
                 user=my.config$user,
                 pass=my.config$pass,
                 host=my.config$host)

logwarn("using UTF8 code")
dbSendQuery(con, "set names utf8")
