#Script for calculating app age and storing it in SQL-Db
#Author: Tim Jonathan Rupp
#DISC applied project

rm(list = ls())

#load required package
library(RSQLite)

#read release date of apps
con <- dbConnect(SQLite(), "app_reviews.sqlite")

dbListTables(con)

age <- dbGetQuery(con, "SELECT app, released FROM app_details;")  

#convert to date format
age$released <- as.Date(age$released, "%b %d, %Y")

#insert missing dates manually
age$released[age$app == "evernote"] <- as.Date("Jan 24, 2012", "%b %d, %Y")
age$released[age$app == "lastpass"] <- as.Date("Dec 2, 2011", "%b %d, %Y")

#calculate age in days
age$age_days <- difftime(as.Date("2021-05-17"), age$released)

#write to db
dbWriteTable(con, "apps", age, overwrite = TRUE)

dbGetQuery(con, "SELECT * FROM apps;")


#add missing release dates in DB
dbExecute(con, "UPDATE app_details
             SET released = 'Jan 24, 2012'
             WHERE app = 'evernote';")

dbExecute(con, "UPDATE app_details
             SET released = 'Dec 2, 2011'
             WHERE app = 'lastpass';")

#Check if it worked
dbGetQuery(con, "SELECT released FROM app_details
           WHERE app = 'evernote'")

dbGetQuery(con, "SELECT released FROM app_details
           WHERE app = 'lastpass'")

#disconnect
dbDisconnect(con)

