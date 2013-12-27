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
## 2013-12-27: matteo redaelli: new file
##

## ############################################
## botHashtag
## ############################################

botHashtag <- function(hashtag, top=20) {
    if( is.null(hashtag) || is.na(hashtag) ) {
        logwarn("hashtag is empty, exiting botHashtag..")
        return(1)
    }
    hashtag <- gsub("%23", "#", hashtag)
    loginfo(sprintf("Bot hashtag=%s", hashtag))
    tweets <- searchTwitter(hashtag, n=1500)

    tot <- length(tweets)
    loginfo(sprintf("Found %d tweets", tot))
    
    if (tot == 0) {
        logwarn("No tweets retreived for hashtag, exiting botHashtag..")
        return(2)
    }
    
    df <- twListToDF(tweets)
    top.agents <- twTopAgents(df, top=5)
    top.hashtags <- tolower(twTopHashtags(df$text, top=5))
    
    logwarn("Adding hashtags to redis queue")
    for (h in setdiff(names(top.hashtags), hashtag)) {
        logwarn(sprintf("hashtag %s", h))
        if(redisSIsMember("twitter:hashtags:visited", h)) {
            logwarn(sprintf("hashtag %s already visited", h))
        } else {
            logwarn(sprintf("adding hashtag %s", h))
            redisSAdd("twitter:hashtags:todo", charToRaw(h))
       }
    }
    top.words <- twTopWords(df$text, top=10, stopwords=my.config$stopwords)
    hashtag.df <- data.frame(id=hashtag,
                             topAgents=dfToText(top.agents),
                             topHashtags=dfToText(top.hashtags),
                             topWords=dfToText(top.words))

    loginfo(sprintf("removing old entry '%s' in hashtags table...", hashtag))
    sql <- sprintf("delete from hashtags where id='%s'", hashtag)
    logdebug(sql)
    dbSendQuery(con, sql)
    
    loginfo("Saving hashtag to hashtags table...")
    dbWriteTable(con, "hashtags", hashtag.df, row.names=FALSE, append=TRUE)                    
    redisSAdd("twitter:hashtags:visited", charToRaw(hashtag))
}

## ############################################
## loading options
## ############################################

args <- commandArgs(TRUE)

source("begin.R")

hashtag <- args[1]

if(!is.na(hashtag)) {
    botHashtag(hashtag)
} else 
    while (1) {
        hashtag <- redisSPop("twitter:hashtags:todo")
        if(is.null(hashtag) || is.na(hashtag))
            break
        else
            tryCatch(
                botHashtag(hashtag),
                error=function(cond) {
                    logerror(cond)
                    redisSAdd("twitter:hashtags:errors", hashtag)
                }
                )
    }

source("end.R")
