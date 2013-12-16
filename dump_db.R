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
## 2013-11-25: matteo redaelli: switching to mysql
##

## ############################################
## dumpOneSearch
## ############################################
dumpOneSearch <- function(record, folder) {
     loginfo(sprintf("Dumping tweets for search %s for the period %s", 
                     record$id,
                     record$dump_date_filter))
     sql <- sprintf("select t.*, s.geocode, s.lang lang_twitter from tweets t inner join search_results r on r.tweet_id=t.id inner join search_for s on r.search_for_id = s.id where search_for_id='%s' and date_format(t.created, '%s') =  '%s'", 
                    record$id,
                    record$dump_period,
                    record$period)
     tweets <- dbGetQuery(con, sql)
     filename <- sprintf("%s_%s.Rdata",
                         record$id, record$period)
     new.folder <- file.path(folder, record$id)
     dir.create(new.folder, showWarnings = FALSE, recursive = FALSE)
     filename <- file.path(new.folder, filename)
     loginfo(sprintf("Saving to file %s", filename))
     save(tweets, file=filename, compress="gzip")
}

## ############################################
## dumpSearches
## ############################################
dumpSearches <- function(folder) {
    loginfo("Dumping searches...")
    search.for <- dbGetQuery(con, "select *, date_format(CURDATE(), dump_period) period from search_for where enabled=1")

    for (c in 1:nrow(search.for)) {
        record <- search.for[c,]
        dumpOneSearch(record, folder)
    }
}

## ############################################
## dumpUsers
## ############################################
dumpUsers <- function(folder) {
    loginfo("Dumping users...")
    users <- dbGetQuery(con, "select * from users")

    filename <- file.path(folder, "users.Rdata")
    loginfo(sprintf("Saving to file %s", filename))
    save(users, file=filename, compress="gzip")
}

## ############################################
## dumpStatsDB
## ############################################
dumpStatsDB <- function(folder) {
    loginfo("Dumping statistics...")
    stats.db <- dbGetQuery(con, "select * from stats_db")
    filename <- file.path(folder, "stats.Rdata")
    save(stats.db, file=filename, compress="gzip")
}

## ############################################
## loading options
## ############################################

source("begin.R")
dumpSearches(my.config$rdata.folder)
dumpUsers(my.config$rdata.folder)
dumpStatsDB(my.config$rdata.folder)
source("end.R")
