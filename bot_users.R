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

library(getopt)
source("config.R")
source("db_connect.R")
source("twitter_connect.R")

## ############################################
## botUserTimeline
## ############################################
botUserTimeline <- function(id, sinceID, includeRts=TRUE) {
    logwarn(sprintf("Getting timeline for id=%s, sinceID=%s", id, sinceID))
    tweets <- userTimeline(id, sinceID=sinceID, includeRts=includeRts, n=1000)
    saveTweetsAndSinceID(id, tweets, sinceID.table="bot_users", results.table=NULL)
}

## ############################################
## botUsersTimelines
## ############################################
botUsersTimelines <- function(sleep=5) {
    logwarn("Starting bot timelines...")
    search.for <- dbGetQuery(con, "select * from bot_users where enabled=1")

    for (c in 1:nrow(search.for)) {
        record <- search.for[c,]
        logwarn(sprintf("ID=%s, sinceID=%s", record$id, record$sinceid))
        try(botUserTimeline(record$id, sinceID=record$sinceid))
        try(botUsers(record$id, depth=1, include.followers=TRUE, include.friends=TRUE))
        loginfo("Sleeping some seconds...")
        Sys.sleep(sleep)
    }
}

## ############################################
## loading options
## ############################################

## get options, using the spec as defined by the enclosed list.
## we read the options from the default: commandArgs(TRUE).
spec = matrix(c(
    'verbose', 'v', 2, "integer",
    'help' , 'h', 0, "logical",
    'followers' , 'f', 0, "logical",
    'friends' , 'F', 0, "logical",
    'new' , 'n', 0, "logical",
    'existing' , 'e', 0, "logical",
    'timeline' , 't', 0, "logical",
    'id' , 'i', 1, "character"
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
if ( is.null(opt$new ) ) { opt$new = FALSE }
if ( is.null(opt$existing ) ) { opt$existing = FALSE }
if ( is.null(opt$followers ) ) { opt$followers = FALSE }
if ( is.null(opt$friends ) ) { opt$friends = FALSE }
if ( is.null(opt$timeline ) ) { opt$timeline = FALSE }
if ( is.null(opt$verbose ) ) { opt$verbose = FALSE }


botUsersTimelines(my.config$sleep.dump)
dbDisconnect(con)

