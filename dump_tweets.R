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
  'export.uid' , 'e', 1, "character",
  'db' , 'd', 1, "character",
  'remove' , 'r', 1, "character",
  'records' , 'N', 1, "integer",
  'show' , 's', 0, "logical",
  'version' , 'V', 0, "logical"
  ), byrow=TRUE, ncol=4)

opt = getopt(spec);

## ############################################
## CMD help
## ############################################
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
## set some reasonable defaults for the options that are needed,
## but were not specified.
if ( is.null(opt$db ) ) { opt$db = "db/" }
if ( is.null(opt$records ) ) { opt$records = 1500 }

twitter.db <- file.path(opt$db, "twitter.db")

## ############################################
## CMD export.uid
## ############################################
if ( !is.null(opt$export.uid ) ) {
  loginfo(paste("Exporting tweets for UID", opt$export.uid))
      
  tag.db <- file.path(opt$db, paste("s", opt$export.uid, "db", sep="."))
  tag.conn <- dbConnect("SQLite", dbname = tag.db)

  if(dbExistsTable(tag.conn, "tweets")) {
    tweets_df<- dbReadTable(tag.conn, "tweets")
    tweets_df$created <- as.POSIXct(tweets_df$created, origin="1970-01-01")
    save(tweets_df, file=sprintf("%s.Rdata", opt$export.uid))
  } else {
    logwarn("table tweets does not exist! Nothing to do, Bye!")
  }
  
  q(status=1)
}

db.conn <- dbConnect("SQLite", dbname = twitter.db)
if(dbExistsTable(db.conn, "search")) {
  search <-dbGetQuery(db.conn, "select * from search")
} else {
  search <- NULL
}

## ############################################
## CMD remove
## ############################################
if ( !is.null(opt$remove) ) {
  sql <- sprintf("delete from search where uid='%s'", opt$remove)
  loginfo(sql)
  dbGetQuery(db.conn, sql)
}

## ############################################
## CMD add
## ############################################
if ( !is.null(opt$add) ) {
  search <- read.csv(opt$add, header=T)
  append <- FALSE
  if(dbExistsTable(db.conn, "search")) 
    append <- TRUE

  loginfo(sprintf("Importing searches from file %s with option append=%s", opt$add, as.character(append)))

  dbWriteTable(db.conn, "search", search, append = append)
}

dbDisconnect(db.conn)

## ############################################
## CMD show
## ############################################
if ( !is.null(opt$show ) ) {
  print(search)
}

## ############################################
## CMD 
## ############################################
if ( is.null(opt$add) & is.null(opt$show) & is.null(opt$remove) ) {
  logwarn("Retreiving twitter credentials from file twitCred.Rdata")
  ## cred <- OAuthFactory$new(consumerKey="XXXX",
  ##                         consumerSecret="XX",
  ##                         requestURL="https://api.twitter.com/oauth/request_token",
  ##                         accessURL="http://api.twitter.com/oauth/access_token",
  ##                         authURL="http://api.twitter.com/oauth/authorize")
  ##cred$handshake()
  load("twitCred.Rdata")
  registerTwitterOAuth(twitCred)

  search <- subset(search, enabled=1)
  if(!is.null(search) & nrow(search) >=1) {
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
     
