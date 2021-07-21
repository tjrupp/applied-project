#Script for merging tables in Db 
#Author: Tim Jonathan Rupp
#DISC applied project

rm(list = ls())

#load required package
library(RSQLite)

#connect an list tables
con <- dbConnect(SQLite(), "app_reviews.sqlite")

dbListTables(con)

#create list and store tables to be merged
list <- list()

list[[1]] <- dbGetQuery(con, "SELECT * FROM apps;")
list[[2]] <- dbGetQuery(con, "SELECT * FROM mean_ratings;")
list[[3]] <- dbGetQuery(con, "SELECT * FROM update_frequency")
list[[4]] <- dbGetQuery(con, "SELECT * FROM mean_sentiment")
list[[5]] <- dbGetQuery(con, "SELECT * FROM app_details;")

#bind tables together
data <- bind_cols(list)

#remove duplicated columns
remove <- grep("app...", colnames(data))[2:5]
remove <- append(remove, grep("released...", colnames(data))[2])

data <- data[, -remove]
colnames(data)[1:2] <- c("app", "released")

#write table (overwrite old one)
dbWriteTable(con, "apps", data, overwrite = TRUE)

#remove other merged tables
dbRemoveTable(con, "mean_ratings")
dbRemoveTable(con, "update_frequency")
dbRemoveTable(con, "app_details")
dbRemoveTable(con, "mean_sentiment")
dbRemoveTable(con, "review_sentiment")

#check if everything worked
dbGetQuery(con, "SELECT * FROM apps LIMIT 5;")

#disconnect
dbDisconnect(con)

