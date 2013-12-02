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
## botUsers
## ############################################
botUsers <- function(users.id, depth=0, include.followers=FALSE, include.friends=FALSE, n=5000) {
    if (length(users.id) == 0) {
        logwarn("No users to be bot!!")
    } else {
        logwarn(sprintf("twitter lookup %d users", length(users.id)))
        users <- lookupUsers(users.id)
        users.ldf <- lapply(users, as.data.frame)
        users.df <- do.call("rbind", users.ldf)

        logwarn("saving data to users table...")
        try(dbWriteTable(con, "users", users.df, row.names=FALSE, append=TRUE))

        logwarn(sprintf("depth=%d", depth))
        if (depth <= 0) {
           logwarn("no recursion")
           return(0)
        }
        depth.new <- depth - 1
        if (include.followers) {
           logwarn("Retriving followers...")
           users.id <- lapply(users, function(u) u$getFollowerIDs(n=n))
           logwarn("Bot followers...")
           lapply(users.id, function(id) botUsers(id, depth=depth.new, include.followers=FALSE, include.friends=FALSE))
        }
        if (include.friends) {
           logwarn("Retriving friends")
           users.id <- lapply(users, function(u) u$getFriendIDs(n=n))
           logwarn("Bot friends...")
           lapply(users.id, function(id) botUsers(id, depth=depth.new, include.followers=FALSE, include.friends=FALSE))
        }
        return(0)
    }
}
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
