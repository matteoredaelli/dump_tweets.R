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

library(twitteR)
library(textcat)

#source("twitter-utils.R")

chunk <- function(x,n=500) split(x, factor(sort(rank(x)%%n)))

mygetFollowerIDs <- function(user) {
    followers.count <- as.integer(user$followersCount)
    loginfo(sprintf("followersCount=%d for user %s - %s",
                    followers.count,
                    user$id,
                    user$screenName))
    if(followers.count == 0) {
        result <- c()
    } else {
        loginfo(sprintf("Retriving followers for user %s - %s",
                        user$id,
                        user$screenName))
        result <- tryCatch({user$getFollowerIDs()
                         }, warning = function(w) {
                             loginfo(w)
                             c()
                         }, error = function(e) {
                             loginfo(e)
                             c()
                         }, finally = {
                             c()
                         })
        loginfo(sprintf("found %s followers", length(result)))
    }
    return (result)
}

mygetFriendIDs <- function(user) {
    friends.count <- as.integer(user$friendsCount)
    loginfo(sprintf("friendsCount=%d for user %s - %s", 
                    friends.count,
                    user$id,
                    user$screenName))

    if(friends.count == 0) {
        result <- c()
    } else {
        loginfo(sprintf("Retriving friends for user %s - %s",
                        user$id,
                        user$screenName))
        result <- tryCatch({user$getFriendIDs()
                        }, warning = function(w) {
                            loginfo(w)
                            c()
                        }, error = function(e) {
                            loginfo(e)
                            c()
                        }, finally = {
                            c()
                        })
        loginfo(sprintf("found %s friends", length(result)))
    }
    return (result)
}

## ############################################
## saveTweetsAndSinceID
## ############################################
saveTweetsAndSinceID <- function(id, tweets, sinceID.table=NULL, results.table=NULL) {
    tot <- length(tweets)
    loginfo(sprintf("Found %d tweets", tot))
    if(tot == 0) {
        loginfo("No tweets found!!")
    } else if (!is.null(tweets[1]$error)) {
        logwarn("Error, no retreived tweets")
        loginfo(sprintf("ERROR: %s", tweets[1]$error))
    } else {
        logdebug("Converting tweets list to a dataframe")
        tweets_df = twListToDF(tweets)
        
        #tweets_df$text <- unlist(lapply(tweets_df$text, function(t) iconv(t, to="UTF8")))
        ##tweets_df$text <- iconv(tweets_df$text, to="UTF8")

        ##tweets_df$text <- unlist(lapply(tweets_df$text, function(t) normalizzaTesti(t)))
        #tweets_df$text <- normalizzaTesti(tweets_df$text)
        tweets_df$text <- preprocessingEncoding(tweets_df$text)
        #tweets_df$text <- normalizeUTF8text(tweets$text)
        #tweets_df$lang <- textcat(tweets$text, ECIMCI_profiles)


        maxID <- max(tweets_df$id)
        loginfo(sprintf("maxID=%s", maxID))

        loginfo("Saving data to tweet table...")
        dbWriteTable(con, "tweets", tweets_df, row.names=FALSE, append=TRUE)

        if (!is.null(results.table)) {
            loginfo(sprintf("saving data to %s table...", results.table))
            results <- data.frame(id=id, tweet_id=tweets_df$id)
            dbWriteTable(con, results.table, results, row.names=FALSE, append=TRUE)
        }
        
        if (!is.null(sinceID.table) & id > 0) {
            loginfo(sprintf("updating table %s...", sinceID.table))
            sql <- sprintf("update %s set sinceid=%s where id='%s'", sinceID.table, maxID, id)
            loginfo(sql)
            dbSendQuery(con, sql)
        }
    }
}

analyzeTweets <- function(df, top=20) {
    top.agents <- twTopAgents(df, top=3)
    top.hashtags <- twTopHashtags(df$text, top=top)
    top.users <- twTopUsers(df, top=top)
    top.retwittingUsers <- twTopRetwittingUsers(df$text, top=top)
    ## TODO
    top.words <- twTopWords(df$text, top=top, stopwords=my.config$stopwords)
    ##top.words <- data.frame()

    logwarn("Adding hashtags to redis queue")
    queueAddTodoHashtags(names(top.hashtags))
    
    logwarn("Adding users to redis queue")
    queueAddTodoLookupsUsers(names(top.users))
    
    data.frame(
        topAgents=dfToText(top.agents),
        topHashtags=dfToText(top.hashtags),
        ##topWords="",
        topWords=dfToText(top.words),
        topUsers=dfToText(top.users),
        topRetwittingUsers=dfToText(top.retwittingUsers))
}

## ############################################
## loading options
## ############################################

loginfo("Connecting to TWITTER...")
          
setup_twitter_oauth(
    consumer_key = my.config$consumer_key,
    consumer_secret = my.config$consumer_secret,
    access_token = my.config$access_token,
    access_secret = my.config$access_secret, 
    credentials_file=NULL
    )
