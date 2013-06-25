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
##
##

##################################################################
## TODO
##################################################################
## 1) managing options since,until, lang
##
##

library(twitteR)
library(RSQLite)
library(getopt)
library(logging)

## log setup
basicConfig()

#get options, using the spec as defined by the enclosed list.
#we read the options from the default: commandArgs(TRUE).
spec = matrix(c(
  'verbose', 'v', 2, "integer",
  'help' , 'h', 0, "logical",
  'add' , 'a', 1, "character",
  'db' , 'd', 1, "character",
  'records' , 'n', 1, "integer",
  'show' , 's', 0, "logical",
  'version' , 'V', 0, "logical"
  ), byrow=TRUE, ncol=4)

opt = getopt(spec);
# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) {
  cat(getopt(spec, usage=TRUE))
  q(status=1);
}

if ( !is.null(opt$version) ) {
  cat("version 0.1\n")
  q(status=1)
}
#set some reasonable defaults for the options that are needed,
#but were not specified.
if ( is.null(opt$db ) ) { opt$db = "db/" }
if ( is.null(opt$records ) ) { opt$records = 15 }
twitter.db <- file.path(opt$db, "twitter.db")
db.conn <- dbConnect("SQLite", dbname = twitter.db)
if(dbExistsTable(db.conn, "search")) {
  search <-dbGetQuery(db.conn, "select * from search where enabled=1")
} else {
  search <- NULL
}

if ( !is.null(opt$add) ) {
  search <- read.csv(opt$add, header=T)
  append <- FALSE
  if(dbExistsTable(db.conn, "search")) 
    append <- TRUE
  
  dbWriteTable(db.conn, "search", search, append = append)
}

dbDisconnect(db.conn)

if ( !is.null(opt$show ) ) {
  print(search)
}

if ( is.null(opt$add) &  is.null(opt$show) ) {
  ## cred <- OAuthFactory$new(consumerKey="XXXX",
  ##                         consumerSecret="XX",
  ##                         requestURL="https://api.twitter.com/oauth/request_token",
  ##                         accessURL="http://api.twitter.com/oauth/access_token",
  ##                         authURL="http://api.twitter.com/oauth/authorize")
  ##cred$handshake()
  
  load("twitCred.Rdata")
  registerTwitterOAuth(twitCred)

  if(!is.null(search)) {
    for (c in seq(1,nrow(search))) {
      record <- search[c,]
      loginfo(paste("Dump tweets for", record$tag))
      
      tag.db <- file.path(opt$db, paste("s", record$uid, "db", sep="."))
      tag.conn <- dbConnect("SQLite", dbname = tag.db)

      if(dbExistsTable(tag.conn, "options")) {
        logwarn("table options does already exist")
        options <- dbReadTable(tag.conn, "options")
      } else {
        logwarn("table options does not exist")
        options <- data.frame(sinceID="000000000000000000")
      }
      
      sinceID <- options$sinceID[1]
      since <- record$since
      until <- record$until
      
      logwarn(sprintf("sinceID=%s, since=%s, until=%s", sinceID, since, until))

      tweets <- searchTwitter(record$tag, n=opt$records, sinceID=sinceID, since=since, until=until)

      if (length(tweets) == 0) {
        logwarn("No tweets found!!")
      } else {
        tweets_df = twListToDF(tweets)
        logwarn(sprintf("Found %d tweets", nrow(tweets_df)))
        
        maxID <- max(tweets_df$id)
        logwarn(sprintf("maxID=%s", maxID))
        options <- data.frame(sinceID=maxID)
        if(dbExistsTable(tag.conn, "tweets"))
          append <- TRUE
        else
          append <- FALSE
        dbWriteTable(tag.conn, "tweets", tweets_df, append = append)
        if(dbExistsTable(tag.conn, "options"))
          dbRemoveTable(tag.conn, "options")
        dbWriteTable(tag.conn, "options", options, append = FALSE)
      }
      dbDisconnect(tag.conn)
      
      loginfo("Sleeping some seconds before a new twitter search")
      Sys.sleep(5)
    }
  }
}
     
