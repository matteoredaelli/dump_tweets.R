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
## 2013-01-25: matteo redaelli: first release
##
##

my.config <- list(
    ## #################################
    ## database
    ## #################################
    host     = "localhost",
    db       = "twitter",
    user     = "root",
    pass     = "",
    ## #################################
    ## search twitter
    ## #################################
    consumer_key    = 'XXX',
    consumer_secret = 'XXX',
    access_token    = "XXX",
    access_secret   = "XXX",
    sleep.dump      = 5,
    ## #################################
    ## dump
    ## #################################
    rdata.folder    = ".",
    last=1
    )
