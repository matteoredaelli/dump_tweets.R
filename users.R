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
## botUserTimeline
## ############################################
botUserTimeline <- function(id, sinceID, includeRts=TRUE) {
    loginfo(sprintf("Getting timeline for id=%s, sinceID=%s", id, sinceID))
    tweets <- userTimeline(id, sinceID=sinceID, includeRts=includeRts, n=1000)
    saveTweetsAndSinceID(id, tweets, sinceID.table="bot_users", results.table=NULL)
}

## ############################################
## botUsersTimelines
## ############################################
botUsersTimelines <- function(include.followers=TRUE, include.friends=TRUE) {
    loginfo("Starting bot timelines...")
    search.for <- dbGetQuery(con, "select * from bot_users where enabled=1")

    for (c in 1:nrow(search.for)) {
        record <- search.for[c,]
        loginfo(sprintf("ID=%s, sinceID=%s", record$id, record$sinceid))
        try(botUserTimeline(record$id, sinceID=record$sinceid))
        try(botUsers(record$id, include.followers=include.followers, include.friends=include.friends))
        loginfo("Sleeping some seconds...")
        Sys.sleep(5)
    }
}


## ############################################
## botExistingUsers
## ############################################
botQueueUsers <- function(buffer=100, sleep=5, include.followers=TRUE, include.friends=TRUE) {
    loginfo("bot users from Queue")
    while (1) {
        users <- myredisSMultiPop("twitter:users:todo", buffer=buffer)
        
        tot <- length(users)
        loginfo(sprintf("Got %d users from queue", tot))
        
        if(is.null(users) || is.na(users) || tot == 0)
            break
        else
            tryCatch(
                botUsers(users, include.followers=include.followers, include.friends=include.friends),
                error=function(cond) {
                    logerror(cond)
                    sapply(users, function(u) redisSAdd("twitter:users:errors", u))
                }
                )
    }
}

## ###########################################
## loading options
## ############################################

## get options, using the spec as defined by the enclosed list.
## we read the options from the default: commandArgs(TRUE).
spec = matrix(c(
    'verbose',      'v', 2, "integer",
    'help',         'h', 0, "logical",
    'followers',    'f', 0, "logical",
    'friends',      'F', 0, "logical",
    'queue',        'q', 0, "logical",
    'timeline',     't', 0, "logical",
    'id',           'i', 1, "character"
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

if ( is.null(opt$queue ) ) { opt$queue = FALSE }
if ( is.null(opt$followers ) ) { opt$followers = FALSE }
if ( is.null(opt$friends ) ) { opt$friends = FALSE }
if ( is.null(opt$timeline ) ) { opt$timeline = FALSE }
if ( is.null(opt$verbose ) ) { opt$verbose = FALSE }
if ( is.null(opt$id ) ) { opt$id = FALSE }

if( opt$timeline )
   botUsersTimelines(include.followers=opt$followers, include.friends=opt$friends)

if( opt$id )
    botUsers(id, include.followers=opt$followers, include.friends=opt$friends)

if( opt$queue )
    botQueueUsers(include.followers=opt$followers, include.friends=opt$friends)


source("end.R")

