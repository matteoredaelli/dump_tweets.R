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
drop_old_db_entries <- function(period.format, period.value) {
    loginfo(sprintf("Dropping tweets for period %s (%s)", 
                    period.value,
                    period.format))
    sql <- sprintf("delete from tweets where date_format(t.ts, '%s') < '%s'", 
                   period.format,
                   period.value)
    
    logdebug(sql)
    dbSendQuery(con, sql)

    sql <- sprintf("delete from users where date_format(t.ts, '%s') < '%s'", 
                   period.format,
                   period.value)
    
    logdebug(sql)
    dbSendQuery(con, sql)
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

if (is.null(opt$period.value) ) 
    opt$period.format <- "2014-01"

drop_old_db_entries(my.config$rdata.folder,
                    period.format=opt$period.format,
                    period.value=opt$period.value)
source("end.R")
