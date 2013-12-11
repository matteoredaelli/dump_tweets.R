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

library(twitteR)

chunk <- function(x,n=500) split(x, factor(sort(rank(x)%%n)))

## ############################################
## botUsers
## ############################################
botFewUsers <- function(users.id, depth=0, include.followers=TRUE, include.friends=TRUE, already.visited=c(), n=2000) {
    if (length(users.id) == 0) {
        logwarn("No users to be bot!!")
    } else {
        already.visited <- c(users.id, already.visited)
        logwarn(sprintf("twitter lookup %d users", length(users.id)))
        users <- lookupUsers(users.id)
        users.ldf <- lapply(users, as.data.frame)
        users.df <- do.call("rbind", users.ldf)

        logwarn("saving users to users table...")
        try(dbWriteTable(con, "users", users.df, row.names=FALSE, append=TRUE))

        logwarn(sprintf("depth=%s", depth))
        if (depth <= 0) {
           logwarn("end of recursion")
           return(0)
        }
        depth.new <- depth - 1
        followers.id <- friends.id <- c()

        if (include.followers) {
           logwarn("Retriving followers...")
           for (i in 1:length(users)) {
              logwarn(sprintf("Retriving followers for %s", users[[i]]$name))
              some.id <- tryCatch({users[[i]]$getFollowerIDs()
                                  }, warning = function(w) {
                                   logwarn("warning!")
                                   c()
                                  }, error = function(e) {
                                   logwarn("error!")
                                   c()
                                  }, finally = {
                                   c()
                                  })
              logwarn(sprintf("found %s followers", length(some.id)))
              followers.id <- c(followers.id, some.id)
              Sys.sleep(my.config$sleep.dump)
           }
           logwarn(sprintf("found %d followers", length(followers.id)))
        }
        Sys.sleep(my.config$sleep.dump)
        if (include.friends) {
           logwarn("Retriving friends")
           for (i in 1:length(users)) {
              logwarn(sprintf("Retriving friends for %s", users[[i]]$name))
              some.id <- tryCatch({users[[i]]$getFriendIDs()
                                  }, warning = function(w) {
                                   logwarn("warning!")
                                   c()
                                  }, error = function(e) {
                                   logwarn("error!")
                                   c()
                                  }, finally = {
                                   c()
                                  })
              logwarn(sprintf("found %s friends", length(some.id)))
              friends.id <- c(friends.id, some.id)
              Sys.sleep(my.config$sleep.dump)
           }
           logwarn(sprintf("found %d friends", length(friends.id)))
        }

        users.id <- unique(c(followers.id, friends.id))
        if (is.null(users.id) || length(users.id) == 0) {
          logwarn("no followers and/or friends to be crawled")
        } else {
          logwarn(sprintf("Crawling &d followers and/or friends...", length(users.id)))
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
  logwarn(sprintf("Found in %d users, reduced to %d after removing already visited users", tot.orig, tot))
  if(!is.null(users.id) && tot > 100) {
    split.by <- as.integer(tot / 100) + 1
    logwarn(sprintf("splitting users in %d groups", split.by))
    users.id.list <- chunk(users.id, split.by)
    lapply(users.id.list, function(id.list) botFewUsers(id.list, depth=depth, include.followers=include.followers, include.friends=include.friends, already.visited=already.visited, n=n))
  } else {
    botFewUsers(users.id, depth=depth, include.followers=include.followers, include.friends=include.friends, already.visited=already.visited, n=n)
  } 
}

## ############################################
## loading options
## ############################################

logwarn("Connecting to TWITTER...")
          
setup_twitter_oauth(
    consumer_key = 'm3GtR24P1biGReMyRdffg',
    consumer_secret = 'zbLnjPFSA8reqhDgpOEEc6JlvE25nSOBRSSzyXZY',
    access_token = "162665531-9qnOlxB7Ol4dxVlp0CAKjSi46khkThSbLXrYK1q3",
    access_secret = "L8OVVvHlL20IxJF9j4tgYiSBurcKlZ0384Ki4vvBM", 
    credentials_file=NULL
    )
