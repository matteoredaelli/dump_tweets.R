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

#################################################################
## file history
##################################################################
## 2013-06-24: matteo redaelli: first release
##
##


source("begin.R")

library(lattice)

library(ggplot2)
library(lattice)
library(stringr)
library(ggplot2)
library(reshape2)
library(igraph)
library(tm)
library(wordcloud)
library(RColorBrewer)
library(cluster)
library(FactoMineR)
#get options, using the spec as defined by the enclosed list.
#we read the options from the default: commandArgs(TRUE).
spec = matrix(c(
  'verbose'   ,'v', 2, "integer",
  'help'      ,'h', 0, "logical",
  'directory' ,'d', 1, "character",
  'height'    ,'H', 1, "integer",
  'width'     ,'W', 1, "integer",
  'user'      ,'u', 1, "character",
  'query'     ,'q', 1, "character",
  'tz'        ,'t', 1, "integer",
  'top'       ,'T', 1, "integer",
  'color'     ,'c', 1, "logical",
  'stopwords' ,'s', 1, "logical",
  'version'   ,'V', 0, "logical"
  ), byrow=TRUE, ncol=4)

opt = getopt(spec);
# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) || (is.null(opt$user) && is.null(opt$query))) {
  cat(getopt(spec, usage=TRUE))
  q(status=1);
}

if ( !is.null(opt$version) ) {
  cat("version 0.2\n")
  q(status=1)
}

#set some reasonable defaults for the options that are needed,
#but were not specified.
if ( is.null(opt$color ) ) { opt$color = "red" }
if ( is.null(opt$height ) ) { opt$height = 900 } else {opt$height = as.integer(opt$height)}
if ( is.null(opt$width ) ) { opt$width = 900 } else {opt$width = as.integer(opt$width)}
if ( is.null(opt$tz ) ) { opt$tz = "Europe/Rome" }
if ( is.null(opt$top ) ) { opt$top = 10 }
if ( is.null(opt$directory ) ) { opt$directory = "." }

if ( is.null(opt$stopwords) ) {
  opt$stopwords <- stopwords('english')
} else {
  opt$stopwords <- eval(parse(text=opt$stopwords))
}

loginfo(sprintf("Stopwords: %s", paste(opt$stopwords, sep=",", collapse=",")))

if (!is.null(opt$user)) {
  loginfo(sprintf("Loading tweets for user %s", opt$user))
  sql <- sprintf("select * from tweets where screenName='%s'", opt$user)
  tweets.df <- dbGetQuery(con, sql)
} else {
  loginfo(sprintf("Searching tweets about '%s'", opt$query))
  tweets <- searchTwitter(opt$query, n=1500)
  tweets.df <- twListToDF(tweets)
}

AnalyzeTweets(tweets.df, top=opt$top, 
              stopwords=opt$stopwords, tz=opt$tz, 
              output.dir=opt$directory, chart.color=opt$color, 
              chart.width=opt$width, chart.height=opt$height)

# todo: http://bodongchen.com/blog/2013/02/demo-of-using-twitter-hashtag-analytics-package-to-analyze-tweets-from-lak13/

source("end.R")
