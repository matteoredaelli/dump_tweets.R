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
## 2013-11-26: matteo redaelli: first release
##

##################################################################
## TODO
##################################################################
## 
##
##

library(logging)
library(getopt)
library(RMySQL)

source("config.R")
basicConfig()
source("twitter.R")


## ############################################
## loading options
## ############################################
loginfo(sprintf("Connecting to database=%s, host=%s with user=%s",
                my.config$db, my.config$host, my.config$user))

con <- dbConnect(MySQL(),
                 db=my.config$db,
                 user=my.config$user,
                 pass=my.config$pass,
                 host=my.config$host)

loginfo("using UTF8 code")
dbSendQuery(con, "set names utf8")
