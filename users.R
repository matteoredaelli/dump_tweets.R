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
botUserTimeline <- function(id, sinceID=1, includeRts=TRUE, save=FALSE) {
    loginfo(sprintf("Getting timeline for id=%s, sinceID=%s", id, sinceID))
    tweets <- userTimeline(id, sinceID=sinceID, includeRts=includeRts, n=1000)

    if(length(tweets) == 0) {
        logwarn(sprintf("No timeline retreived for user id=%s, sinceID=%s", id, sinceID))
        redisSAdd("twitter:users:timelines:noresults", charToRaw(id))
        return(0)
    }
    
    if(save)
        saveTweetsAndSinceID(id, tweets, sinceID.table="bot_users", results.table=NULL)

    df = twListToDF(tweets)
    timelines.df <- analyzeTweets(df, top=20)
    timelines.df <- cbind(id=id, timelines.df)

    loginfo(sprintf("removing old entry '%s' in timelines table...", id))
    sql <- sprintf("delete from timelines where id='%s'", id)
    logdebug(sql)
    dbSendQuery(con, sql)
    
    loginfo("Saving data to timelines table...")
    dbWriteTable(con, "timelines", timelines.df, row.names=FALSE, append=TRUE)                    
    redisSAdd("twitter:users:timelines:visited", charToRaw(id))
}

## ############################################
## botUsersTimelines
## ############################################
botUsersTimelines <- function(include.followers=TRUE, include.friends=TRUE, save=TRUE) {
    loginfo("Starting bot timelines...")
    search.for <- dbGetQuery(con, "select * from bot_users where enabled=1")

    for (c in 1:nrow(search.for)) {
        record <- search.for[c,]
        loginfo(sprintf("ID=%s, sinceID=%s", record$id, record$sinceid))
        try(botUsers(record$id, include.followers=include.followers, include.friends=include.friends, include.timelines=TRUE, save=save))
        loginfo("Sleeping some seconds...")
        Sys.sleep(5)
    }
}


## ############################################
## botLookupsQueueUsers
## ############################################
botLookupsQueueUsers <- function(buffer=100, sleep=5, includeRts=TRUE) {
    loginfo("bot users from Lookups Queue")
    while (1) {
        user <- myredisSMultiPop("twitter:users:lookups:todo", buffer=buffer)
        
        tot <- length(users)
        loginfo(sprintf("Got %d users from queue", tot))
        
        if(is.null(users) || is.na(users))
            break
        
        tryCatch(
            botUsers(users,
                     include.followers=include.followers,
                     include.friends=include.friends,
                     include.timelines=include.timelines),
            error=function(cond) {
                logerror(cond)
                sapply(users, function(u) redisSAdd("twitter:users:lookups:errors", charToRaw(u)))
            }
            )
    }
}

## ############################################
## botTimelinessQueueUsers
## ############################################
botTimelinesQueueUsers <- function(includeRts=TRUE, sleep=5, save=FALSE) {
    loginfo("bot users from Timelines Queue")
    while (1) {
        user <- redisSPop("twitter:users:timelines:todo")
        if(is.null(user) || is.na(user))
            break
   
        loginfo(sprintf("Got %s user from queue", user))
        
        if(is.null(user) || is.na(user))
            break

        tryCatch(
            botUserTimeline(user, sinceID=1, includeRts=includeRts, save=save),
            error=function(cond) {
                logerror(cond)
                redisSAdd("twitter:users:timelines:errors", charToRaw(user))
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
    'verbose',           'v', 2, "integer",
    'help',              'h', 0, "logical",
    'followers',         'f', 0, "logical",
    'friends',           'F', 0, "logical",
    'queueLookups',      'L', 0, "logical",
    'queueTimelines',    'T', 0, "logical",
    'timelines',         't', 0, "logical",
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

if ( is.null(opt$queueLookups) ) { opt$queueLookups = FALSE }
if ( is.null(opt$queueTimelines) ) { opt$queueTimelines = FALSE }
if ( is.null(opt$followers ) ) { opt$followers = FALSE }
if ( is.null(opt$friends ) ) { opt$friends = FALSE }
if ( is.null(opt$timelines ) ) { opt$timelines = FALSE }
if ( is.null(opt$verbose ) ) { opt$verbose = FALSE }
if ( is.null(opt$id ) ) { opt$id = FALSE }

if( opt$timelines )
   botUsersTimelines(include.followers=opt$followers, include.friends=opt$friends, save=TRUE)

if( opt$id )
    botUsers(id, include.followers=opt$followers, include.friends=opt$friends, include.timelines=opt$timelines, save=FALSE)

if( opt$queueLookups)
    botLookupsQueueUsers(include.followers=opt$followers,
                         include.friends=opt$friends)

if( opt$queueTimelines)
    botTimelinesQueueUsers()

source("end.R")

