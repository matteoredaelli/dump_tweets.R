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
## 2014-02-07: matteo redaelli: switching to mysql
##

## ############################################
## dumpOneSearch
## ############################################
clean_db <- function(period.format, period.value=NULL) {
    if(is.null(period.value)) {
        sql <- sprintf("select date_format(CURDATE(), '%s')", period.format)
        period.value <- dbGetQuery(con, sql)[1,][1]
    }
    loginfo(sprintf("Dropping tweets for period %s (%s)", 
                    period.value,
                    period.format))
    sql <- sprintf("delete from tweets where date_format(ts, '%s') < '%s'", 
                   period.format,
                   period.value)
    logdebug(sql)
    rs <- dbSendQuery(con, sql)
    tot <- dbGetInfo(rs, what = "rowsAffected")
    logdebug(sprintf("rowsAffected=%s", tot))

    sql <- sprintf("delete from users where date_format(ts, '%s') < '%s'", 
                   period.format,
                   period.value)
    logdebug(sql)
    rs <- dbSendQuery(con, sql)
    tot <- dbGetInfo(rs, what = "rowsAffected")
    logdebug(sprintf("rowsAffected=%s", tot))
}

source("begin.R")

## ############################################
## loading options
## ############################################

## get options, using the spec as defined by the enclosed list.
## we read the options from the default: commandArgs(TRUE).
spec = matrix(c(
    'help',         'h', 0, "logical",
    'period.format','f', 1, "character",
    'period.value', 'v', 1, "character"
    ), byrow=TRUE, ncol=4);

opt = getopt(spec);

## if help was asked for print a friendly message
## and exit with a non-zero error code
if ( !is.null(opt$help) ) {
    cat(getopt(spec, usage=TRUE));
    q(status=1);
}

if (is.null(opt$period.format) ) 
    opt$period.format <- "%Y-%v"

clean_db(period.format=opt$period.format,
                    period.value=opt$period.value)
source("end.R")
