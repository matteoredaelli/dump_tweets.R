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
## 2013-1-27: matteo redaelli: first release
##

##################################################################
## TODO
##################################################################
##
##

source("begin.R")


## ############################################
## botNewUsers
## ############################################
botNewUsers <- function(include.followers=TRUE, include.friends=TRUE, n=2000) {
    loginfo("Bot new users")
    sql <- "select distinct screenName id from tweets where screenName not in (select screenName from users)"
    loginfo(sql)
    users <- dbGetQuery(con, sql)

    botUsers(users$id,
             include.followers=include.followers,
             include.friends=include.friends,
             n=n)
}

## ############################################
## botFewUsers
## ############################################
botFewUsers <- function(users.id, include.followers=TRUE, include.friends=TRUE, n=2000) {
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
botUsers <- function(users.id, include.followers=TRUE, include.friends=TRUE, n=2000) {
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
                n=n)
  } 
}

## get options, using the spec as defined by the enclosed list.
## we read the options from the default: commandArgs(TRUE).
spec = matrix(c(
    'verbose',           'v', 2, "integer",
    'help',              'h', 0, "logical",
    'followers',         'f', 0, "logical",
    'friends',           'F', 0, "logical",
    'id',                'i', 1, "character"
    ), byrow=TRUE, ncol=4);

opt = getopt(spec);
## if help was asked for print a friendly message
## and exit with a non-zero error code
if ( !is.null(opt$help) ) {
    cat(getopt(spec, usage=TRUE));
    q(status=1);
}
## set some reasonable defaults for the options that are needed,
## but were not specified.

if ( is.null(opt$followers ) ) { opt$followers = FALSE }
if ( is.null(opt$friends ) ) { opt$friends = FALSE }
if ( is.null(opt$verbose ) ) { opt$verbose = FALSE }


if( !is.null(opt$id)) {
    botUsers(opt$id, include.followers=opt$followers, include.friends=opt$friends, include.timelines=FALSE)
} else {
    botNewUsers(include.followers=opt$followers, include.friends=opt$friends)
}
source("end.R")

