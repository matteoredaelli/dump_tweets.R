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

## ############################################
## botUserTimeline
## ############################################
botUserTimeline <- function(id, sinceID, includeRts=TRUE) {
    logwarn(sprintf("Getting timeline for id=%s, sinceID=%s", id, sinceID))
    tweets <- userTimeline(id, sinceID=sinceID, includeRts=includeRts)
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
        loginfo("Sleeping some seconds...")
        Sys.sleep(sleep)
    }
}

## ############################################
## loading options
## ############################################

source("config.R")
source("db_connect.R")
source("twitter_connect.R")
botUsersTimelines(my.config$sleep.dump)
dbDisconnect(con)

