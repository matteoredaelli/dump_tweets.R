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
## 2013-11-26: matteo redaelli: first release
##

##################################################################
## TODO
##################################################################
##
##

library(twitteR)

## ############################################
## loading options
## ############################################

logwarn("Connecting to TWITTER...")
          
setup_twitter_oauth(
    consumer_key = 'm3GtR24P1biGReMyRdffg',
    consumer_secret = 'zbLnjPFSA8reqhDgpOEEc6JlvE25nSOBRSSzyXZY',
    access_token = "162665531-9qnOlxB7Ol4dxVlp0CAKjSi46khkThSbLXrYK1q3",
    access_secret = "L8OVVvHlL20IxJF9j4tgYiSBurcKlZ0384Ki4vvBM", 
    credentials_file=NULL
    )
