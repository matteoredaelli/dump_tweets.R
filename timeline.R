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
## 2014-01-22: matteo redaelli: first release
##

##################################################################
## TODO
##################################################################
##
##

## ############################################
## timelineOne
## ############################################
timelineOne <- function(id, sinceID=1, includeRts=TRUE, save=FALSE) {
    loginfo(sprintf("Timeline for userid=%s, sinceID=%s", id, sinceID))
    tweets <- userTimeline(id, sinceID=sinceID, includeRts=includeRts, n=1000)

    if( length(tweets) == 0) {
        logwarn(sprintf("No tweets found timelineing for id=%s, sinceID=%s", id, sinceID))
    } else {
        if(save)
            saveTweetsAndSinceID(id, tweets, sinceID.table="timeline_for", results.table="timeline_results")
        else
            saveTweetsAndSinceID(id, tweets, sinceID.table=NULL, results.table=NULL)

    }
}

## ############################################
## timelineFor
## ############################################
timelineFor <- function(sleep=5, includeRts=TRUE) {
    loginfo("Starting timelinees...")
    timeline.for <- dbGetQuery(con, "select * from timeline_for where enabled=1 order by ts")

    for (c in 1:nrow(timeline.for)) {
        record <- timeline.for[c,]
        loginfo(sprintf("ID=%s, SINCEID=%s", record$id, record$sinceid))
        timelineOne(record$id,
                      sinceID=record$sinceid, includeRts=includeRts, save=TRUE
        )
        loginfo("Sleeping some seconds before a new twitter timeline")
        Sys.sleep(sleep)
    }
}

## ############################################
## loading options
## ############################################

source("begin.R")

## get options, using the spec as defined by the enclosed list.
## we read the options from the default: commandArgs(TRUE).
spec = matrix(c(
    'verbose',           'v', 2, "integer",
    'help',              'h', 0, "logical",
    'user',              'u', 1, "character"
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

if ( is.null(opt$verbose) ) { opt$verbose = FALSE }
##if ( is.null(opt$user) ) { opt$user = FALSE }

if (!is.null(opt$user)) {
    sql <- sprintf("insert into timeline_for (id) values('%s')", opt$user)
    try(dbSendQuery(con, sql))
    timelineOne(id=opt$user)
} else {
    timelineFor()
}

source("end.R")
