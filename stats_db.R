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
## 2013-11-27: matteo redaelli: new file
##

## ############################################
## StatsDB
## ############################################
StatsDB <- function(folder) {
    logwarn("Dumping statistics...")
    records <- dbGetQuery(con, "select count(*) from users")
    users <- as.integer(records[1][1])
    records <- dbGetQuery(con, "select count(*) from search_tweets")
    tweets <- as.integer(records[1][1])
    records <- dbGetQuery(con, "select count(*) from search_for")
    searches <- as.integer(records[1][1])
    
    sql <- sprintf("delete from stats_db where day='%s'", format(Sys.Date(), "%Y%m%d"))
    dbSendQuery(con, sql)
    
    sql <- sprintf("insert into stats_db (day, users, tweets, searches) values ('%s', '%d', '%d', '%d')",
                   format(Sys.Date(), "%Y%m%d"), users, tweets, searches)
    logwarn(sql)
    dbSendQuery(con, sql)
    return(0)
}

## ############################################
## loading options
## ############################################

source("config.R")
source("db_connect.R")
StatsDB(my.config$rdata.folder)
dbDisconnect(con)
