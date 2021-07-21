#Script for calculating mean sentiment per app 
#and storing in SQLite-Db
#Author: Tim Jonathan Rupp
#DISC applied project

rm(list = ls())

#load required packages
library(RSQLite)
library(dplyr)

#connect to DB
con <- dbConnect(SQLite(), "app_reviews.sqlite")

#list tables
dbListTables(con)

#sentiment of each review
sentiment <- dbGetQuery(con, "SELECT app, ave_sentiment FROM reviews")

#calculate mean sentiment per app
sentiment %>%
  group_by(app) %>%
  summarise(mean_sentiment = mean(ave_sentiment)) ->
  mean_sentiment

#save in db
dbWriteTable(con, "mean_sentiment", mean_sentiment)

#disconnect
dbDisconnect(con)
