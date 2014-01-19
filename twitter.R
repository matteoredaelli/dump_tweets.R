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

source("twitter-utils.R")

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
    if (length(tweets) == 0) {
        loginfo("No tweets found!!")
    } else if (!is.null(tweets[1]$error)) {
        loginfo(sprintf("ERROR: %s", tweets$error))
    } else {
        tweets_df = twListToDF(tweets)
        loginfo(sprintf("Found %d tweets", nrow(tweets_df)))
        
        #tweets_df$text <- unlist(lapply(tweets_df$text, function(t) iconv(t, to="UTF8")))
        tweets_df$text <- iconv(tweets_df$text, to="UTF8")


        #tweets_df$text <- normalizeUTF8text(tweets$text)
        #tweets_df$lang <- textcat(tweets$text, ECIMCI_profiles)


        maxID <- max(tweets_df$id)
        loginfo(sprintf("maxID=%s", maxID))

        loginfo("Saving data to tweet table...")
        dbWriteTable(con, "tweets", tweets_df, row.names=FALSE, append=TRUE)

        if (!is.null(results.table)) {
            loginfo(sprintf("saving data to %s table...", results.table))
            results <- data.frame(search_for_id=id, tweet_id=tweets_df$id)
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
## botUsers
## ############################################
botFewUsers <- function(users.id, include.followers=TRUE, include.friends=TRUE, n=2000, include.timelines=TRUE) {
    if (length(users.id) == 0) {
        loginfo("No users to be bot!!")
    } else {
        loginfo(sprintf("twitter lookup for %d users", length(users.id)))
        logwarn(sprintf("twitter lookup users: %s", paste(users.id, collapse=", ")))
        users <- lookupUsers(users.id)
        users.ldf <- lapply(users, as.data.frame)
        users.df <- do.call("rbind", users.ldf)

        users.count <- nrow(users.df)
        if (is.null(users.df) || users.count == 0) {
          loginfo("No users retreived. Something went wrong")
          return(1)
        }
        loginfo("saving users to users table...")
        try(dbWriteTable(con, "users", users.df, row.names=FALSE, append=TRUE))
        
        loginfo("adding users to visited users queue")
        sapply(users.df$id, function(id) redisSAdd("twitter:users:lookups:visited", charToRaw(id)))

        if (include.timelines) 
            queueAddTodoTimelinesUsers(users.df$id)
        
        followers.id <- friends.id <- c()

        if (include.followers) {
           loginfo("Retriving followers...")
           for (i in 1:length(users)) {
               some.id <- mygetFollowerIDs(users[[i]])
               followers.id <- c(followers.id, some.id)
               Sys.sleep(my.config$sleep.dump)
           }
           loginfo(sprintf("found %d followers", length(followers.id)))
       }
        Sys.sleep(my.config$sleep.dump)
        if (include.friends) {
           loginfo("Retriving friends")
           for (i in 1:length(users)) {
               some.id <- mygetFriendIDs(users[[i]])
               friends.id <- c(friends.id, some.id)
               Sys.sleep(my.config$sleep.dump)
           }
           loginfo(sprintf("found %d friends", length(friends.id)))
       }
        
        users.id <- unique(c(followers.id, friends.id))
        loginfo("removing current users from followers and friends..")
        users.id <- setdiff(users.id, users.df$id)
        
        if (is.null(users.id) || length(users.id) == 0) {
            loginfo("no followers and/or friends to be crawled")
        } else {
            queueAddTodoLookupsUsers(users.id)
        }
    }
}

## ############################################
## botUsers
## ############################################
botUsers <- function(users.id, include.followers=TRUE, include.friends=TRUE, include.timelines=TRUE, n=2000) {
  tot <- length(users.id)
  loginfo(sprintf("Found in %d users", tot))
  if(!is.null(users.id) && tot > 100) {
    split.by <- as.integer(tot / 100) + 1
    loginfo(sprintf("splitting users in %d groups", split.by))
    users.id.list <- chunk(users.id, split.by)
    lapply(users.id.list, function(id.list) botFewUsers(id.list, include.followers=include.followers, include.friends=include.friends, n=n))
  } else {
    botFewUsers(users.id,
                include.followers=include.followers,
                include.friends=include.friends,
                include.timelines=include.timelines,
                n=n)
  } 
}

## ############################################
## queue function
## ############################################
queueAddTodo <- function(element, queue.todo, queue.visited) {
    logdebug(sprintf("element %s", element))
    if(redisSIsMember(queue.visited, element)) {
        logdebug(sprintf("element %s already visited", element))
    } else {
        logdebug(sprintf("adding element  %s", element))
        redisSAdd(queue.todo, charToRaw(element))
    }
}

queueAddTodoHashtags <- function(hashtags) {
    loginfo(paste("Adding hashtags to queue: ", paste(hashtags, collapse=", ")))
    sapply(hashtags, function(e) queueAddTodo(e, "twitter:hashtags:todo", "twitter:hashtags:visited"))
}

queueAddTodoLookupsUsers <- function(users) {
    loginfo("Adding users to lookup queue")
    sapply(users, function(e) queueAddTodo(e, "twitter:users:lookups:todo", "twitter:users:lookups:visited"))
}

queueAddTodoTimelinesUsers <- function(users) {
    loginfo("Adding users to timeline queue")
    sapply(users, function(e) queueAddTodo(e, "twitter:users:timelines:todo", "twitter:users:timelines:visited"))
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
