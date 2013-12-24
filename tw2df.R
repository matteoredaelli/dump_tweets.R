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
## botExistingUsers
## ############################################
botExistingUsers <- function(depth=0, sleep=5, include.followers=TRUE, include.friends=TRUE) {
  loginfo(sprintf("bot existing users with depth=%s", depth))
  sql <- "select id from users"
  user.df <- dbGetQuery(con, sql)
  botUsers(user.df$id, depth=depth, include.followers=include.followers, include.friends=include.friends)
}

## ############################################
## botNewUsers
## ############################################
botNewUsers <- function(depth=0, sleep=5, include.followers=TRUE, include.friends=TRUE) {
  loginfo(sprintf("bot new users from tweets with depth=%s", depth))
  sql <- "select distinct screenName id from tweets where screenName not in  (select screenName from users)"
  user.df <- dbGetQuery(con, sql)
  botUsers(user.df$id, depth=depth, include.followers=include.followers, include.friends=include.friends)
}

## ###########################################
## loading options
## ############################################

## get options, using the spec as defined by the enclosed list.
## we read the options from the default: commandArgs(TRUE).
spec = matrix(c(
    'verbose',      'v', 2, "integer",
    'help',         'h', 0, "logical",
    'outputdir',    'd', 1, "character",
    'search',       's', 1, "character",
    'timeline',     't', 1, "character"
    ), byrow=TRUE, ncol=4);

opt = getopt(spec);
## if help was asked for print a friendly message
## and exit with a non-zero error code
if ( !is.null(opt$help) ) {
    cat(getopt(spec, usage=TRUE));
    q(status=1);
}

if (is.null(opt$outputdir)) opt$outputdir <- "."

## ############################################
## timeline
## ############################################

if( !is.null(opt$timeline) ) {
    loginfo(sprintf("Getting timeline for id=%s", opt$timeline))
    tweets <- userTimeline(opt$timeline, includeRts=TRUE, n=3600)
    tweets_df <- twListToDF(tweets)
    filename=paste("timeline-", opt$timeline, ".Rdata", sep="")
    save(tweets_df, file=file.path(opt$outputdir, filename))
}

## ############################################
## search
## ############################################
if( !is.null(opt$search) ) {
    loginfo(sprintf("Getting search q=%s", opt$search))
    tweets <- searchTwitter(opt$search, n=1500)
    tweets_df <- twListToDF(tweets)
    save(tweets_df, file=file.path(opt$outputdir, "search.Rdata"))
}
source("end.R")

