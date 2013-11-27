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
## 2013-11-27: matteo redaelli: first release
##

##################################################################
## TODO
##################################################################
##
##

## ############################################
## searchOne
## ############################################
searchOne <- function(id, q, sinceID) {
    logwarn(sprintf("Searching for q=%s, sinceID=%s", q, sinceID))
}

## ############################################
## botUsers
## ############################################
botUsers <- function() {
    logwarn("Starting bot users...")
    search.for <- dbGetQuery(con, "select id from bot_users where enabled=1")

    if (length(search.for) == 0) {
        logwarn("No users to be bot!!")
    } else {
        logwarn(sprintf("twitter lookup %d users", nrow(search.for)))
        users <- lookupUsers(search.for$id)
        users.ldf <- lapply(users, as.data.frame)
        users.df <- do.call("rbind", users.ldf)

        logwarn("saving data to users table...")
        dbWriteTable(con, "users", users.df, row.names=FALSE, append=TRUE)
    }
}

## ############################################
## loading options
## ############################################

source("config.R")
source("db_connect.R")
source("twitter_connect.R")
botUsers()
dbDisconnect(con)

