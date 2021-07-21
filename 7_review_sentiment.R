#Script for calculating sentiment and storing in SQLite-Db
#Author: Tim Jonathan Rupp
#DISC applied project

rm(list = ls())

#load required packages
library(sentimentr)
library(RSQLite)

#read reviews from DB
con <- dbConnect(SQLite(), "app_reviews.sqlite")

data <- dbGetQuery(con, "SELECT content, ID FROM reviews;")
 
#get sentiment by sentence for each review
sentiment <- sentiment_by(data$content)
colnames(sentiment)[1] <- "ID"

#convert to data frame
sentiment <- as.data.frame(sentiment)

#save in DB
dbWriteTable(con, "review_sentiment", sentiment, overwrite = TRUE)

#join tables together
data <- dbGetQuery(con,
           "SELECT *
            FROM reviews r
            LEFT JOIN review_sentiment s
            ON r.ID = s.ID")

#remove duplicate column
data[, 12] <- NULL

#overwrite old table 
dbWriteTable(con, "reviews", data, overwrite = TRUE)

#check if it worked
dbGetQuery(con, "SELECT COUNT(*) FROM reviews;")

#disconnect
dbDisconnect(con)

