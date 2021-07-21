#Script for saving app reviews in SQLite-Db
#Author: Tim Jonathan Rupp
#DISC applied project

rm(list = ls())

#load required packages
library(stringr)
library(jsonlite)
library(dplyr)
library(RSQLite)

#list JSON files with reviews
files <- list.files("reviews_JSON")

#function to convert from JSON to df and name with app name
save_reviews <- function(x) {
  res <- fromJSON(paste0("reviews_JSON/", x))
  res$app <- str_replace_all(x, "_reviews.json", "")
  return(res)
}

#save in a list and bind rows to one df
res <- lapply(files, save_reviews)
res <- bind_rows(res)

#convert at to Date format to set the relevant time period
res$at <- as.Date(res$at)
res <- subset(res, at < as.Date("2021-05-18") & at > as.Date("2016-05-16"))

#add ID variable for later merging
res$ID <- seq_along(res$at)

#connect to SQLite DB and write reviews
con <- dbConnect(SQLite(), "app_reviews.sqlite")

dbWriteTable(con, "reviews", res)


#check if table is there
dbListTables(con)

dbGetQuery(con, "SELECT * 
           FROM reviews
           WHERE app = 'any.do'
           LIMIT 5;")

#disconnect
dbDisconnect(con)
