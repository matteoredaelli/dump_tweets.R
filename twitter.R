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

chunk <- function(x,n=500) split(x, factor(sort(rank(x)%%n)))


normalizeUTF8text <- function(testo, ...){
	# fonte: http://www.utf8-chartable.de/
	#        http://www.utf8-chartable.de/unicode-utf8-table.pl?start=4736&number=128&utf8=string-literal&unicodeinhtml=dec
	
	# test: http://www.utf8-chartable.de/unicode-utf8-table.pl
	testo <- gsub("\xc3\xa0" ,"ââ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xc3\xa8" ,"â®", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xc3\xa9" ,"â©", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xc3\xac" ,"â¨", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xc3\xad" ,"i", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xc3\xb2" ,"ââ", testo, fixed=TRUE, useBytes=TRUE) 	
	testo <- gsub("\xc3\xba" ,"âÏ", testo, fixed=TRUE, useBytes=TRUE)  

	
	testo <- gsub("\001" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\002" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\003" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\004" ," ", testo, fixed=TRUE, useBytes=TRUE)			
	testo <- gsub("\005" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\006" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\007" ," ", testo, fixed=TRUE, useBytes=TRUE)
#	testo <- gsub("\008" ," ", testo, fixed=TRUE, useBytes=TRUE)
#	testo <- gsub("\009" ," ", testo, fixed=TRUE, useBytes=TRUE)
#	testo <- gsub("\010" ," ", testo, fixed=TRUE, useBytes=TRUE)
#	testo <- gsub("\011" ," ", testo, fixed=TRUE, useBytes=TRUE)
#	testo <- gsub("\012" ," ", testo, fixed=TRUE, useBytes=TRUE)
#	testo <- gsub("\013" ," ", testo, fixed=TRUE, useBytes=TRUE)
#	testo <- gsub("\014" ," ", testo, fixed=TRUE, useBytes=TRUE)
#	testo <- gsub("\015" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\016" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\017" ," ", testo, fixed=TRUE, useBytes=TRUE)
#	testo <- gsub("\018" ," ", testo, fixed=TRUE, useBytes=TRUE)
#	testo <- gsub("\019" ," ", testo, fixed=TRUE, useBytes=TRUE)																
	testo <- gsub("\020" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\021" ,"!", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\022" ,'"', testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\023" ,' ', testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\027" ,"'", testo, fixed=TRUE, useBytes=TRUE)		
	testo <- gsub("\030" ,"'", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\031" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\032" ,"'", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\033" ," ", testo, fixed=TRUE, useBytes=TRUE)		
	testo <- gsub("\034" ,"'", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\035" ,"'", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\036" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\037" ," ", testo, fixed=TRUE, useBytes=TRUE)		
	testo <- gsub("\x80" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x81" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x82" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\x83" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x84" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x85" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x86" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x87" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x88" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x89" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x8a" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\x8b" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\x8c" ," ", testo, fixed=TRUE, useBytes=TRUE)			
	testo <- gsub("\x8d" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\x8e" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\x8f" ," ", testo, fixed=TRUE, useBytes=TRUE)		
	testo <- gsub("\x90" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x91" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\x92" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\x93" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x94" ," ", testo, fixed=TRUE, useBytes=TRUE)
 	testo <- gsub("\x95" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x96" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\x97" ," ", testo, fixed=TRUE, useBytes=TRUE)		
	testo <- gsub("\x98" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x99" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\x9a" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x9b" ," ", testo, fixed=TRUE, useBytes=TRUE)		
	testo <- gsub("\x9c" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\x9d" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x9e" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\x9f" ," ", testo, fixed=TRUE, useBytes=TRUE)							
	testo <- gsub("â¨\xa0" ," ", testo, fixed=TRUE, useBytes=TRUE) # strange	
	testo <- gsub("\xa0" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xa1" ,"!", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xa2" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xa3" ,"L", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xa4" ," ", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xa5" ," ", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xa6" ," ", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xa7" ," ", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xa8" ,'"', testo, fixed=TRUE, useBytes=TRUE) # modified					
	testo <- gsub("\xa9" ,"C", testo, fixed=TRUE, useBytes=TRUE) # modified			
	testo <- gsub("\xaa" ," ", testo, fixed=TRUE, useBytes=TRUE) # modified		
	testo <- gsub("\xab" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xac" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xad" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xae" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xaf" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xb0" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xb1" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xb2" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xb3" ," ", testo, fixed=TRUE, useBytes=TRUE)		
	testo <- gsub("\xb4" ,"'", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xb5" ,"u", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xb6" ," ", testo, fixed=TRUE, useBytes=TRUE)		
	testo <- gsub("\xb7" ," ", testo, fixed=TRUE, useBytes=TRUE) # modified		
	testo <- gsub("\xb8" ,",", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xb9" ,"1", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xba" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xbb" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xbc" ," ", testo, fixed=TRUE, useBytes=TRUE)		
	testo <- gsub("\xbd" ," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xbe" ," ", testo, fixed=TRUE, useBytes=TRUE)		
	testo <- gsub("\xbf" ,"?", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xc0" ,"A", testo, fixed=TRUE, useBytes=TRUE) # modified		
	testo <- gsub("\xc1" ,"A", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xc2" ,"ââ", testo, fixed=TRUE, useBytes=TRUE) # modified		
	testo <- gsub("\xc3" ,"â®", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xc4" ,"a", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xc5" ,"A", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xc6" ," ", testo, fixed=TRUE, useBytes=TRUE)		
	testo <- gsub("\xc7" ,"âÃ", testo, fixed=TRUE, useBytes=TRUE)		
	testo <- gsub("\xc8" ,"â®", testo, fixed=TRUE, useBytes=TRUE) # modified
	testo <- gsub("\xc9" ,"â©", testo, fixed=TRUE, useBytes=TRUE) # modified
	testo <- gsub("\xca" ,"E", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xcb" ,"E", testo, fixed=TRUE, useBytes=TRUE) # modified		
	testo <- gsub("\xcc" ,"â¨", testo, fixed=TRUE, useBytes=TRUE) # modified
	testo <- gsub("\xcd" ,"I", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xce" ," ", testo, fixed=TRUE, useBytes=TRUE) 	
	testo <- gsub("\xcf" ," ", testo, fixed=TRUE, useBytes=TRUE) 		
	testo <- gsub("\xe0" ,"ââ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xe1" ,"a", testo, fixed=TRUE, useBytes=TRUE) # modified
	testo <- gsub("\xe2" ,"a", testo, fixed=TRUE, useBytes=TRUE) # modified 	 
	testo <- gsub("\xe3" ,"a", testo, fixed=TRUE, useBytes=TRUE) # modified 
	testo <- gsub("\xe4" ,"a", testo, fixed=TRUE, useBytes=TRUE) # modified		
	testo <- gsub("\xe5" ,"a", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xe6" ,"ae", testo, fixed=TRUE, useBytes=TRUE) # modified			
	testo <- gsub("\xe7" ,"âÃ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xe8" ,"â®", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xe9" ,"â©", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xea" ,"e", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xeb" ,"e", testo, fixed=TRUE, useBytes=TRUE) # modified		
	testo <- gsub("\xec" ,"â¨", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xed" ,"i", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xee" ,"i", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xef" ,"i", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xd0" ,"D", testo, fixed=TRUE, useBytes=TRUE) # modified			
	testo <- gsub("\xd1" ,"N", testo, fixed=TRUE, useBytes=TRUE) # modified
	testo <- gsub("\xd2" ,"O", testo, fixed=TRUE, useBytes=TRUE) # modified		
	testo <- gsub("\xd3" ,"O", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xd4" ,"O", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xd5" ,"O", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xd6" ,"O", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xd7" ,"x", testo, fixed=TRUE, useBytes=TRUE) # modified		
	testo <- gsub("\xd8" ,"O", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xd9" ,"U", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xda" ,"U", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xdb" ," ", testo, fixed=TRUE, useBytes=TRUE) 
	testo <- gsub("\xdc" ," ", testo, fixed=TRUE, useBytes=TRUE) 			
	testo <- gsub("\xdd" ,"Y", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xde" ," ", testo, fixed=TRUE, useBytes=TRUE) # modified			
	testo <- gsub("\xdf" ," ", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xf0" ," ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xf1" ,"n", testo, fixed=TRUE, useBytes=TRUE)			
	testo <- gsub("\xf2" ,"ââ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xf3" ,"o", testo, fixed=TRUE, useBytes=TRUE) # modified
	testo <- gsub("\xf4" ,"o", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xf5" ,"o", testo, fixed=TRUE, useBytes=TRUE) # modified 	
	testo <- gsub("\xf6" ,"o", testo, fixed=TRUE, useBytes=TRUE) # modified	
	testo <- gsub("\xf8" ,"o", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xf9" ,"âÏ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xfa" ,"âÏ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\xfb" ,"âÏ", testo, fixed=TRUE, useBytes=TRUE)	
	testo <- gsub("\xfc" ,"u", testo, fixed=TRUE, useBytes=TRUE) # modified 
	testo <- gsub("\xfd" ,"y", testo, fixed=TRUE, useBytes=TRUE) # modified 
	testo <- gsub("\xfe" ,"y", testo, fixed=TRUE, useBytes=TRUE) # modified 		
	testo <- gsub("(\U3e35393c ? \U3e35393c)" ," ", testo, fixed=TRUE, useBytes=TRUE)			
  
	testo <- gsub("\n"," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\r"," ", testo, fixed=TRUE, useBytes=TRUE)
	testo <- gsub("\t"," ", testo, fixed=TRUE, useBytes=TRUE)
}


## ############################################
## saveTweetsAndSinceID
## ############################################
saveTweetsAndSinceID <- function(id, tweets, sinceID.table, results.table=NULL) {
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
        
        loginfo(sprintf("updating table %s...", sinceID.table))
        sql <- sprintf("update %s set sinceid=%s where id='%s'", sinceID.table, maxID, id)
        loginfo(sql)
        dbSendQuery(con, sql)
    }
}

## ############################################
## botUsers
## ############################################
botFewUsers <- function(users.id, depth=0, include.followers=TRUE, include.friends=TRUE, already.visited=c(), n=2000) {
    if (length(users.id) == 0) {
        loginfo("No users to be bot!!")
    } else {
        already.visited <- c(users.id, already.visited)
        loginfo(sprintf("twitter lookup for %d users", length(users.id)))
        logwarn(sprintf("twitter lookup users: %s", paste(users.id, collapse=", ")))
        users <- lookupUsers(users.id)
        users.ldf <- lapply(users, as.data.frame)
        users.df <- do.call("rbind", users.ldf)

        users.count <- nrow(users.df)
        if (is.null(users.df) || users.count == 0) {
          loginfo("No users retreived. Something went wrong")
          return(already.visited)
        }
        loginfo("saving users to users table...")
        try(dbWriteTable(con, "users", users.df, row.names=FALSE, append=TRUE))

        loginfo(sprintf("depth=%s", depth))
        if (depth <= 0) {
           loginfo("end of recursion")
           return(0)
        }
        depth.new <- depth - 1
        followers.id <- friends.id <- c()

        if (include.followers) {
           loginfo("Retriving followers...")
           for (i in 1:length(users)) {
              followers.count <- as.integer(users[[i]]$followersCount)
              loginfo(sprintf("followersCount=%d for user %s - %s",
                              followers.count,
                              users[[i]]$id,
                              users[[i]]$name))
              if(followers.count > 0) {
                loginfo(sprintf("Retriving followers for user %s - %s",
                                users[[i]]$id,
                                users[[i]]$name))
                some.id <- tryCatch({users[[i]]$getFollowerIDs()
                                    }, warning = function(w) {
                                     loginfo(w)
                                     c()
                                    }, error = function(e) {
                                     loginfo(e)
                                     c()
                                    }, finally = {
                                     c()
                                    })
                loginfo(sprintf("found %s followers", length(some.id)))
                followers.id <- c(followers.id, some.id)
                Sys.sleep(my.config$sleep.dump)
            }
           }
           loginfo(sprintf("found %d followers", length(followers.id)))
        }
        Sys.sleep(my.config$sleep.dump)
        if (include.friends) {
           loginfo("Retriving friends")
           for (i in 1:length(users)) {
              friends.count <- as.integer(users[[i]]$friendsCount)
              loginfo(sprintf("friendsCount=%d for user %s - %s", 
                              friends.count,
                              users[[i]]$id,
                              users[[i]]$name))
              if(friends.count > 0) {
                loginfo(sprintf("Retriving friends for user %s - %s",
                                users[[i]]$id,
                                users[[i]]$name))
                some.id <- tryCatch({users[[i]]$getFriendIDs()
                                    }, warning = function(w) {
                                     loginfo(w)
                                     c()
                                    }, error = function(e) {
                                     loginfo(e)
                                     c()
                                    }, finally = {
                                     c()
                                    })
                loginfo(sprintf("found %s friends", length(some.id)))
                friends.id <- c(friends.id, some.id)
                Sys.sleep(my.config$sleep.dump)
            }
           }
           loginfo(sprintf("found %d friends", length(friends.id)))
        }

        users.id <- unique(c(followers.id, friends.id))
        if (is.null(users.id) || length(users.id) == 0) {
          loginfo("no followers and/or friends to be crawled")
        } else {
          loginfo(sprintf("Crawling &d followers and/or friends...", length(users.id)))
          try(lapply(users.id, function(id) botUsers(id, 
                                                      depth=depth.new,
                                                      include.followers=include.followers,
                                                      include.friends=include.friends,
                                                      already.visited = already.visited
                                                      )))
        }
    }
}

## ############################################
## botUsers
## ############################################
botUsers <- function(users.id, depth=0, include.followers=TRUE, include.friends=TRUE, already.visited=c(), n=2000) {
  tot.orig <- length(users.id)
  users.id <- setdiff(users.id, already.visited)
  tot <- length(users.id)
  loginfo(sprintf("Found in %d users, reduced to %d after removing already visited users", tot.orig, tot))
  if(!is.null(users.id) && tot > 100) {
    split.by <- as.integer(tot / 100) + 1
    loginfo(sprintf("splitting users in %d groups", split.by))
    users.id.list <- chunk(users.id, split.by)
    lapply(users.id.list, function(id.list) botFewUsers(id.list, depth=depth, include.followers=include.followers, include.friends=include.friends, already.visited=already.visited, n=n))
  } else {
    botFewUsers(users.id, depth=depth, include.followers=include.followers, include.friends=include.friends, already.visited=already.visited, n=n)
  } 
}

## ############################################
## loading options
## ############################################

loginfo("Connecting to TWITTER...")
          
setup_twitter_oauth(
    consumer_key = 'm3GtR24P1biGReMyRdffg',
    consumer_secret = 'zbLnjPFSA8reqhDgpOEEc6JlvE25nSOBRSSzyXZY',
    access_token = "162665531-9qnOlxB7Ol4dxVlp0CAKjSi46khkThSbLXrYK1q3",
    access_secret = "L8OVVvHlL20IxJF9j4tgYiSBurcKlZ0384Ki4vvBM", 
    credentials_file=NULL
    )
