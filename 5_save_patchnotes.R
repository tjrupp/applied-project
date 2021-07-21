#Script for saving app patchnotes in SQLite-Db
#Author: Tim Jonathan Rupp
#DISC applied project

rm(list = ls())

#load required packages
library(stringr)
library(readr)
library(RSQLite)
library(dplyr)

#list txt files with patchnotes
files <- list.files("Patchnotes_Apps")


#function to extract patchnotes, date, version number and app name 
extract_notes <- function(x) {
  data <- read_file(paste0("Patchnotes_Apps/", x))
  data <- str_split(data, "\\s+(?=Version \\d+)")
  version <- str_extract_all(data[[1]], "^Version [^(]+\\b")
  date <- str_match_all(data[[1]], "^Version [^(]+\\b(.+)")
  for (i in seq_along(date)) {
    date[[i]] <- date[[i]][,2]
  }
  date <- lapply(date, as.Date, " (%b %e, %Y)")
  content <- str_replace_all(data[[1]], "^Version [^(]+\\b \\(.+\\)", " ")
  content <- str_replace_all(content, "\\\n", "")
  content <- str_replace_all(content, "[^[:alnum:]]", " ")
  content <- str_replace_all(content, "[[:digit:]]", " ")
  content <- str_trim(content)
  content[which(content == "")] <- NA
  version <- as.data.frame(t(as.data.frame(version)))
  date <- as.data.frame(t(as.data.frame(date)))
  content <- as.data.frame(content)
  res <- as.data.frame(cbind(version, date, content))
  res$app <- NA
  res$app <- str_replace_all(x, ".txt", "")
  colnames(res) <- c("version", "date", "content", "app")
  rownames(res) <- NULL
  return(res)
}

#use on every file for each app
res <- lapply(files, extract_notes)

#bind to single data frame
res <- bind_rows(res)

#convert date to Date format
res$date <- as.Date(res$date)

#subset relevant time frame
res <- subset(res, date > as.Date("2016-05-16"))

#write to DB
con <- dbConnect(SQLite(), "app_reviews.sqlite")
dbWriteTable(con, "patchnotes", res, overwrite = TRUE)


#check if it worked
dbListTables(con)

dbGetQuery(con, "SELECT * 
           FROM patchnotes
           WHERE app = 'any.do'
           LIMIT 5")

#disconnect
dbDisconnect(con)

