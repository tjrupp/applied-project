#Script for saving app details in SQLite-Db
#Author: Tim Jonathan Rupp
#DISC applied project

rm(list = ls())

#load required packages

library(stringr)
library(jsonlite)
library(dplyr)
library(RSQLite)

#list JSON files
files <- list.files("app_JSON")

#save app details
save_app <- function(x) {
  res <- fromJSON(paste0("app_JSON/", x))
  
  #remove lists in list to be abled to convert to data.frame
  for (i in seq_along(res)) {
    if (length(res[[i]]) > 1) { 
      res[[i]] <- "removed"
    }
  }
  #set NULL-values to NA
  for (i in seq_along(res)) {
    if (is.null(res[[i]])) { res[[i]] <- NA }
  }
  
  #replace for having proper name
  res$app <- str_replace_all(x, "_app.json", "")   
  return(res)
}

#use function on every JSON file
res <- lapply(files, save_app)

#remove lists in list
for (i in seq_along(res)) {
  res[[i]]["comments"] <- NULL
}

#convert contents of list to df
res <- lapply(res, as.data.frame)

#and bind to data.frame
res <- bind_rows(res)

#write to database and check if it worked
con <- dbConnect(SQLite(), "app_reviews.sqlite")

dbWriteTable(con, "app_details", res, overwrite = TRUE)

dbListTables(con)

dbGetQuery(con, "SELECT * 
           FROM app_details
           WHERE app = 'any.do';")

#disconnect
dbDisconnect(con)

