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


dfToText <- function(df, sep=":", eol=",", row.names=TRUE, col.names=FALSE, quote=FALSE) {
    if(is.na(df) || is.null(df) || length(df) == 0)
        return(NA)
   
    capture.output(write.table(df, row.names=row.names, col.names=col.names, eol=eol, quote=quote, sep=sep))
}

twNormalizeDate <- function(df, tz) {
    df$created <- as.POSIXct(format(df$created, tz=tz, usetz=TRUE))
    df <- tweets_df[with(df, order(created)), ]
    #df <- df[37:nrow(df),]
    return(df)
}


twTopAttribute <- function(df, attribute, top=10) {
    t <- rev(sort(table(df[[attribute]])))
    if( top < length(t))
        t <- t[1:top]
    return(t)
}

twTopUsers<- function(df, top=10) {
    return(twTopAttribute(df, attribute="screenName", top=top))
}

twTopAgents <- function(df, top=10) {
    if(is.null(df) || nrow(df) == 0)
        return(NULL)
    
    d <- df$statusSource
    d <- gsub("  ", " ", d)
    d <- gsub("Twitter for", "", d)
    d <- gsub("</a>", "", d)
    d <- strsplit(d, ">")
    d <- sapply(d, function(x) ifelse(length(x) > 1, x[2], x[1]))
    t <- sort(table(d), decreasing=TRUE)
    if( top < length(t))
        t <- t[1:top]
    return(t)
}

twTopLinks <- function(text, top=10) {
    t <- table(unlist(lapply(strsplit(try.tolower(text), '[ :.,;]'), function(w) grep('http[s]?://.+', w, value=TRUE))))
    if( length(t) == 0) {
        logwarn("Found 0 occurrences in twTopLinks")
        return(NULL)
    }
    
    t <- sort(t, decreasing=TRUE)
    if( top < length(t))
        t <- t[1:top]
    return(t)
}

twTopHashtags <- function(text, top=10) {
    ##t <- tolower(unlist(lapply(strsplit(text, '[ :.,;]'), function(w) grep('#', w, value=TRUE))))
    t <- tolower(unlist(str_extract_all(text, "#[[:alnum:]]+")))
    t <- table(t)
    if( length(t) == 0) {
        logwarn("Found 0 occurrences in twTopHashtags")
        return(NULL)
    }
    
    t <- sort(t, decreasing=TRUE)

    if( top < length(t))
        t <- t[1:top]

    return(t)
}

twTopRetwittingUsers <- function(text, top=10) {
    ## TODO: the regular expression may not be correct.. sometimes I see @_opesource_
    #users.list <- str_extract_all(text, "(RT|via)((?:\\b\\W*@\\w+)+)")
    #users <- unlist(users.list)
    #users <- gsub(":", "", users) 
    #users <- gsub("(RT @|via @)", "", users, ignore.case=TRUE) 
    #TODO : managing VIA
    users <- gsub("^RT @([^:]+):.*", "\\1", text, perl=TRUE)
    t <- table(users)
    if( length(t) == 0) {
        logwarn("Found 0 occurrences in twTopRetwittingUsers")
        return(NULL)
    }
    
    t <- sort(t, decreasing=TRUE)

    if( top < length(t))
        t <- t[1:top]
    
    #names(t) <- tolower(names(t))
    return(t)
}

twTopWords <- function(text=NULL, tdm.matrix=NULL, stopwords=NULL, top=10) {
    if(is.null(tdm.matrix))
        tdm.matrix <- twBuildTDMMatrix(text, stopwords=stopwords, twCleanText=TRUE)
    
    ## get word counts in decreasing order
    t <- sort(rowSums(tdm.matrix), decreasing=TRUE)
 
    if( length(t) == 0) {
        logwarn("Found 0 occurrences in twTopWords")
        return(NULL)
    }
    
    if( top < length(t))
        t <- t[1:top]

    return(t)
}

#########
## tot
##########
twHistTweets <- function(df, breaks="30 mins", output.dir=".", output.file="tweets.png", width=1000, height=500, color="red") {
    filename <- file.path(output.dir, output.file)
    png(filename, width=width, height=height, units="px")
    p <- histogram(cut(df$created, breaks=breaks), scales = list(x = list(rot = 90)), type="count", xlab="time", ylab="tweets", col=color)
    print(p)
    dev.off()
}

#########
## agent
##########
twChartAgents <- function(df, output.dir=".", output.file="agents.png", width=1000, height=500, color="red", top=10) {
    filename <- file.path(output.dir, output.file)
    png(filename, width=width, height=height, units="px")
    sources <- twTopAgents(df, top=top)
    p <- barchart(sources, col=color, xlab="tweets", ylab="people")
    print(p)
    dev.off()
}

#########
## top contributors
##########
twChartAuthors <- function(df, output.dir=".", output.file="authors.png", width=1000, height=500, color="red", top=10) {
    filename <- file.path(output.dir, output.file)
    sources = twTopContributors(df, top=top)
    png(filename, width=width, height=height, units="px")
    p <- barchart(sources, col=color, xlab="tweets", ylab="people")
    print(p)
    dev.off()
}

#########
## retweeed-people
##########
twChartAuthorsWithRetweets <- function(df, output.dir=".", output.file="authors-with-retweets.png", width=1000, height=500, color="red", top=10) {
    filename <- file.path(output.dir, output.file)

    d = aggregate(df$retweetCount, by=list(df$screenName), FUN=sum)
    colnames(d) = c("User", "retweets")

    ##d <- subset(d, retweets>0)
    top <- min(top, nrow(d))
    d <- d[with(d, order(-retweets)),][1:top,]
    
    png(filename, width=width, height=height, units="px")
    p <- barchart( User ~ retweets, data=d, col=color, xlab="retweets", ylab="people")
    print(p)
    dev.off()
}

twChartAuthorsWithReplies <- function(df, output.dir=".", output.file="authors-with-replies.png", width=1000, height=500, color="red", top=10) {
    filename <- file.path(output.dir, output.file)
    png(filename, width=width, height=height, units="px")
    d = table(df[!is.na(df$replyToSID),]$screenName)
    p <- barchart( d, col=color, xlab="replies", ylab="people")
    print(p)
    dev.off()
}

twChartInfluencers <- function(df, output.dir=".", output.file="influencers.png", width=1000, height=500, color="red", top=30, from=1) {
    filename <- file.path(output.dir, output.file)
    
    d = aggregate(df$retweetCount, by=list(df$screenName), FUN=sum)
    colnames(d) = c("User", "retweets")
    d2 <- as.data.frame(table(df$replyToSN))
    colnames(d2) = c("User", "replies")

    m = merge(d, d2, all=TRUE)
    m[is.na(m)] = 0

    d1 <- table(df[["screenName"]])
    d1 <- as.data.frame(d1)
    colnames(d1) = c("User", "tweets")
    
    m2 = merge(m, d1, all=TRUE)
    m2[is.na(m2)] = 0

    top <- min(top, nrow(m2))
    from <- min(from, nrow(m2))
    
    m2 <- m2[with(m2, order(-retweets, -tweets)),][from:top,]

    ##m3 <- m2[order(-m2$tweets),]

    png(filename, width=width, height=height, units="px")
    p <- ggplot(m2, aes(x=tweets, y=retweets, size=replies, label=User),legend=FALSE) +
        geom_point(colour="white", fill="red", shape=21) +
            geom_text(size=4)+ theme_bw()
    print(p)
    dev.off()

    # melt data
    m2.melt <- melt(m2, id.vars = c("User"))

    ## plot (Cleveland dot plot)
    output2.file <-  paste("2", output.file, sep="-")
    filename <- file.path(output.dir, output2.file)
    png(filename, width=width, height=height, units="px")
    p <- ggplot(m2.melt, aes(x = User, y = value, color = variable)) + geom_point() + 
        coord_flip() + ggtitle("Counts of tweets, retweets, and messages") +
            xlab("Counts") + ylab("Users")
    print(p)
    dev.off()
}
 
try.tolower <- function(x) {
    y = NA
    try_error = tryCatch(tolower(x), error=function(e) e)
    if (!inherits(try_error, "error"))
        y = tolower(x)
    return(y)
}

twUTF8FixText <- function(text) {
    iconv(text, to="UTF8")
}

twCleanText <- function(text, remove.retweets=TRUE, remove.at=TRUE) {
    results = text

    results = sapply(results, try.tolower)
    ## remove retweet entities
    if (remove.retweets)
        results = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", results)
    ## remove at people
    if (remove.at)
        results = gsub("@\\w+", "", results)
    ## remove punctuation
    results = gsub("[[:punct:]]", "", results)
    ## remove numbers
    results = gsub("[[:digit:]]", "", results)
    ## remove html links
    results = gsub("http\\w+", "", results)
    ## remove unnecessary spaces
    results = gsub("[ \t]{2,}", "", results)
    results = gsub("^\\s+|\\s+$", "", results)
    ## remove unnecessary newlins
    results = gsub("\\n", " ", results)
    
    names(results) = NULL
    
    ## remove empty results (if any)
    results = results[results != ""]
    return(results)
}

#https://sites.google.com/site/miningtwitter/questions/talking-about/wordclouds/wordcloud1


twBuildTDMMatrix <- function(text, stopwords=c(stopwords("en"), stopwords("it")), twCleanText=FALSE) {
    if(twCleanText)
        text <- twCleanText(text)
    
    ## create a corpus
    corpus <- Corpus(VectorSource(text))

    ## create document term matrix applying some transformations
    tdm <- TermDocumentMatrix(corpus,
                              control = list(removePunctuation = TRUE,
                                  stopwords=stopwords, stemDocument=TRUE,
                                  minWordLength=4,
                                  removeNumbers = TRUE, tolower = FALSE))
    ## define tdm as matrix
    m <- as.matrix(tdm)
    return(m)
}

twChartWordcloud <- function(text=NULL, tdm.matrix=NULL, table=NULL, output.dir=".", output.file="wordcloud.png", width=1000, height=500, my.stopwords=c(stopwords("en"), stopwords("it"))) {
    filename <- file.path(output.dir, output.file)

    if(!is.null(table)) {
        d.temp <- as.data.frame(table)
        word <- rownames(d.temp)
        freq <- d.temp[,1]
    } else {
        if(is.null(tdm.matrix))
            tdm.matrix <- twBuildTDMMatrix(text, stopwords=my.stopwords)
    
        ## get word counts in decreasing order
        word_freqs = sort(rowSums(tdm.matrix), decreasing=TRUE) 
        ## create a data frame with words and their frequencies
        word <- names(word_freqs)
        freq <- word_freqs
    }
    
    png(filename, width=width, height=height, units="px")
    p <- wordcloud(word, freq, random.order=FALSE, max.words=Inf,
                   colors=brewer.pal(8, "Dark2"))
    print(p)
    ##colors=brewer.pal(8, "Dark2"), vfont=c("sans serif","plain"))
    dev.off()
}

twChartGivenTopics <- function(text=NULL, tdm.matrix=NULL, output.dir=".", output.file="given-topics.png", width=1000, height=500,  my.stopwords=c(stopwords("en"), stopwords("it"))) {
    if(is.null(tdm.matrix))
        tdm.matrix <- twBuildTDMMatrix(text, stopwords=my.stopwords)
    
    filename <- file.path(output.dir, output.file)
                        
    ## https://sites.google.com/site/miningtwitter/questions/talking-about/given-topic
    wc = rowSums(tdm.matrix)

    ## get those words above the 3rd quantile
    lim = quantile(wc, probs=0.9)
    good = tdm.matrix[wc > lim,]

    ## remove columns (docs) with zeroes
    good = good[,colSums(good)!=0]
    ## adjacency matrix
    M = good %*% t(good)

    ## set zeroes in diagonal
    diag(M) = 0

    ## graph
    g = graph.adjacency(M, weighted=TRUE,
        mode="undirected",
        add.rownames=TRUE)
    ## layout
    glay = layout.fruchterman.reingold(g)

    ## let's superimpose a cluster structure with k-means clustering
    kmg = kmeans(M, centers=8)
    gk = kmg$cluster

    ## create nice colors for each cluster
    gbrew = c("red", brewer.pal(8, "Dark2"))
    gpal = rgb2hsv(col2rgb(gbrew))
    gcols = rep("", length(gk))
    for (k in 1:8) {
        gcols[gk == k] = hsv(gpal[1,k], gpal[2,k], gpal[3,k], alpha=0.5)
    }

    ## prepare ingredients for plot
    V(g)$size = 10
    V(g)$label = V(g)$name
    V(g)$degree = degree(g)
    ##V(g)$label.cex = 1.5 * log10(V(g)$degree)
    ##V(g)$label.color = hsv(0, 0, 0.2, 0.55)
    V(g)$label.color = "black"
    V(g)$frame.color = NA
    V(g)$color = gcols
    E(g)$color = hsv(0, 0, 0.7, 0.3)

    ## plot
    png(filename, width=width, height=height, units="px") 
    plot(g, layout=glay)
    ##title("\nGiven topics",
    ##      col.main="gray40", cex.main=1.5, family="serif")
    dev.off()
}

twChartWhoRetweetsWhom <- function(df, output.dir=".", output.file="who-retweets-whom.png", width=1000, height=500) {
    filename <- file.path(output.dir, output.file)
 
    ##https://sites.google.com/site/miningtwitter/questions/user-tweets/who-retweet
    dm_txt <- df$text
    ## regular expressions to find retweets

    ## which tweets are retweets
    rt_patterns = grep("(RT|via)((?:\\b\\W*@\\w+)+)", 
        dm_txt, ignore.case=TRUE)

    ## show retweets (these are the ones we want to focus on)
    ## dm_txt[rt_patterns]
    ## create list to store user names
    who_retweet = as.list(1:length(rt_patterns))
    who_post = as.list(1:length(rt_patterns))

    ## for loop
    for (i in 1:length(rt_patterns)) { 
        ## get tweet with retweet entity
        twit = df[rt_patterns[i],]
        ## get retweet source 
        poster = str_extract_all(twit$text,
            "(RT|via)((?:\\b\\W*@\\w+)+)") 
        ## remove ':'
        poster = gsub(":", "", poster) 
        ## name of retweeted user
        who_post[[i]] = gsub("(RT @|via @)", "", poster, ignore.case=TRUE) 
        ## name of retweeting user 
        who_retweet[[i]] = rep(twit$screenName, length(poster)) 
    }

    ## unlist
    who_post = unlist(who_post)
    who_retweet = unlist(who_retweet)
    ## two column matrix of edges
    retweeter_poster = cbind(who_retweet, who_post)

    ## generate graph
    rt_graph = graph.edgelist(retweeter_poster)

    ## get vertex names
    ver_labs = get.vertex.attribute(rt_graph, "name", index=V(rt_graph))
    
    png(filename, width=width, height=height, units="px")  
    
    ## choose some layout
    glay = layout.fruchterman.reingold(rt_graph)

    ## plot
 
    par(bg="white", mar=c(1,1,1,1))
    plot(rt_graph, layout=glay,
         vertex.color=hsv(h=.35, s=1, v=.7, alpha=0.1),
         vertex.frame.color=hsv(h=.35, s=1, v=.7, alpha=0.1),
         vertex.size=5,
         vertex.label=ver_labs,
         vertex.label.family="mono",
         vertex.label.color="blue",
         ##  vertex.label.color=hsv(h=0, s=0, v=.95, alpha=0.5),
         vertex.label.cex=0.85,
         edge.arrow.size=0.8,
         edge.arrow.width=0.5,
         edge.width=3,
         edge.color=hsv(h=.35, s=1, v=.7, alpha=0.4))
# add title
    ##title("\nWho retweets whom",
    ##      cex.main=1, col.main="red", family="mono")
    dev.off()
}


twChartDendrogram <- function(text=NULL, tdm.matrix=NULL, output.dir=".", output.file="dendrogram.png", width=1000, height=500, my.stopwords=c(stopwords("en"), stopwords("it"))) {
    if(is.null(tdm.matrix))
        tdm.matrix <- twBuildTDMMatrix(text, stopwords=my.stopwords)

    m = tdm.matrix
    
    filename <- file.path(output.dir, output.file)
                        

    ## remove sparse terms (word frequency > 90% percentile)
    wf = rowSums(m)
    m1 = m[wf>quantile(wf,probs=0.95), ]

    ## remove columns with all zeros
    m1 = m1[,colSums(m1)!=0]

    ## for convenience, every matrix entry must be binary (0 or 1)
    m1[m1 > 1] = 1

    ## distance matrix with binary distance
    m1dist = dist(m1, method="binary")

    ## cluster with ward method
    clus1 = hclust(m1dist, method="ward")

    ## plot dendrogram
    png(filename, width=width, height=height, units="px") 
    plot(clus1, cex=0.7)
    dev.off()
}
