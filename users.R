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
## 2013-11-27: matteo redaelli: first release
##

##################################################################
## TODO
##################################################################
##
##

chunk <- function(x,n=500) split(x, factor(sort(rank(x)%%n)))

## ############################################
## loading options
## ############################################

source("config.R")
source("db_connect.R")
source("twitter_connect.R")

args <- commandArgs(TRUE)
depth <- as.integer(args[1])

if (is.na(depth))
  depth=0

#logwarn("bot users from table bot_users")
#user.df <- dbGetQuery(con, "select id from bot_users")
#botUsers(user.df$id, depth=0)

logwarn(sprintf("bot users from tweets with depth=%s", depth))
sql <- "select id from users"
user.df <- dbGetQuery(con, sql)
tot.rows <- nrow(user.df)
logwarn(sprintf("found %d users", tot.rows))

if(!is.null(user.df) && tot.rows > 500) {
  split.by <- as.integer(tot.rows / 500) + 1
  logwarn(sprintf("splitting users in %d groups", split.by))
  users.id.list <- chunk(user.df$id, split.by)
  lapply(users.id.list, function(id.list) botUsers(id.list, depth=depth))
} else {
  botUsers(user.df$id, depth=depth)
} 

#
dbDisconnect(con)

