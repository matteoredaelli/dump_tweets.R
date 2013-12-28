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
## 2013-06-24: matteo redaelli: first release
## 2013-11-25: matteo redaelli: switching to mysql
##

##################################################################
## TODO
##################################################################
## 1) managing options since,until, lang
##
##

## ############################################
## searchOne
## ############################################
searchOne <- function(id, q, sinceID, geocode=NULL, lang=NULL) {
    if( is.na(geocode) || geocode=='') geocode <- NULL
    if( is.na(lang) || lang=='') lang <- NULL
    loginfo(sprintf("Searching for q=%s, sinceID=%s", q, sinceID))
    tweets <- searchTwitter(q, n=1500, sinceID=sinceID, geocode=geocode, lang=lang)

    if( length(tweets) == 0) {
        logwarn(sprintf("No tweets found searching for q=%s, sinceID=%s", q, sinceID))
    } else {
        saveTweetsAndSinceID(id, tweets, sinceID.table="search_for", results.table="search_results")

        df <- twListToDF(tweets)
    
        ## push hashtags to queue
        top.hashtags <- twTopHashtags(df$text, top=10)
        queueAddTodoHashtags(names(top.hashtags))
        ##push users to queue
        users <- unique(df$screenName)
        try(botUsers(users, include.followers=FALSE, include.friends=FALSE))
    }
}

## ############################################
## searchFor
## ############################################
searchFor <- function(sleep=5) {
    loginfo("Starting searches...")
    search.for <- dbGetQuery(con, "select * from search_for where enabled=1")

    for (c in 1:nrow(search.for)) {
        record <- search.for[c,]
        loginfo(sprintf("ID=%s, q=%s, SINCEID=%s", record$id, record$q, record$sinceid))
        try(searchOne(record$id,
                      record$q, 
                      sinceID=record$sinceid,
                      geocode=record$geocode,
                      lang=record$lang
        ))
        loginfo("Sleeping some seconds before a new twitter search")
        Sys.sleep(sleep)
    }
}

## ############################################
## loading options
## ############################################

source("begin.R")
searchFor(my.config$sleep.dump)
source("end.R")
