#Script for calculating mean rating of reviews 
#and saving it in SQLite-Db
#Author: Tim Jonathan Rupp
#DISC applied project

rm(list = ls())

#load required packages
library(RSQLite)
library(dplyr)

#connect to SQLite DB
con <- dbConnect(SQLite(), "app_reviews.sqlite")

dbListTables(con)

#select app and score
ratings <- dbGetQuery(con, "SELECT app, score FROM reviews;")

#calculate mean rating of reviews and store in mean_ratings and number 
#of reviews
ratings %>%
  select(app, score) %>%
  group_by(app) %>%
  summarise(mean_reviews = mean(score), n = n()) ->
  mean_ratings

#get mean rating in store
mean_store <- dbGetQuery(con, "SELECT app, score FROM app_details")

#join tables together
mean_ratings <- left_join(mean_ratings, mean_store, by = "app")

#rename columns
colnames(mean_ratings)[3:4] <- c("n_reviews", "mean_store" )

#write to table
dbWriteTable(con, "mean_ratings", mean_ratings)

#disconnect
dbDisconnect(con)
