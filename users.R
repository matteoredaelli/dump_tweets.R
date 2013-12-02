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


## ############################################
## loading options
## ############################################

source("config.R")
source("db_connect.R")
source("twitter_connect.R")

logwarn("bot users from table bot_users")
user.df <- dbGetQuery(con, "select id from bot_users")
botUsers(user.df$id)

logwarn("bot users from tweets")
sql <- "select distinct screenName id from tweets minus where screenName not in  (select screenName from users)"
user.df <- dbGetQuery(con, sql)
botUsers(user.df$id)

#
dbDisconnect(con)

