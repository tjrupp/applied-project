#Script for saving app names in SQLite-Db
#Author: Tim Jonathan Rupp
#DISC applied project

rm(list = ls())

#load required packages
library(stringr)
library(jsonlite)
library(dplyr)
library(RSQLite)

#list files and remove "reviews.JSON" ending to get all app names
files <- list.files("reviews_JSON")
app <- str_replace_all(files, "_reviews.json", "")
res <- as.data.frame(app)

#write to table
con <- dbConnect(SQLite(), "app_reviews.sqlite")

dbWriteTable(con, "apps", res, overwrite = TRUE)

dbListTables(con)

#check
dbGetQuery(con, "SELECT * FROM apps")

#disconnect
dbDisconnect(con)
