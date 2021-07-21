#Script for calculating update frequency for each app
#and storing it in SQLite-Db
#Author: Tim Jonathan Rupp
#DISC applied project

rm(list = ls())

#load required packages
library(RSQLite)
library(dplyr)

#connect and load patch note data
con <- dbConnect(SQLite(), "app_reviews.sqlite")

dbListTables(con)

patches <- dbGetQuery(con, "SELECT * 
                               FROM patchnotes;")

#convert to date format
patches$date <- as.Date(patches$date, 
                                 origin = "1970-01-01")

#get first update in time frame per app
patches %>%
    select(app, date) %>% 
    group_by(app) %>% 
    slice(which.min(date)) ->
    update_frequency

#rename to first_update
names(update_frequency)[2] <- "first_update"

#get count of updates per app in time frime
patches %>% 
  group_by(app) %>%
  summarise(n_updates = n_distinct(version)) ->
  update_frequency2

#join both tables together
update_frequency <- left_join(update_frequency, update_frequency2, by = "app")

#calculate time frame in days
update_frequency$difftime <- as.numeric(difftime(as.Date("2021-05-17"), 
                                      update_frequency$first_update)) 

#calculate mean days between updates per app
update_frequency %>%
  mutate(update_frequency = difftime / n_updates) ->
  update_frequency

#convert to list of df for each single app
patches %>% 
  select(app, date) ->
  between_updates

list <- split(between_updates, f = between_updates$app)

#calculate time difference between updates and sd
for (i in seq_along(list)) {
  list[[i]][,2] <- sort(list[[i]][,2])
  list[[i]]$time_diff <- list[[i]][,2] - lag(list[[i]][,2])
  list[[i]]$sd <- sd(list[[i]][,3], na.rm = TRUE)
}

#bind back to one df
res <- bind_rows(list)


#join res and update_frequency together
res %>% 
  group_by(app) %>%
  distinct(sd) %>%  
  left_join(update_frequency, ., by = c("app")) ->
  update_frequency

#write to DB
dbWriteTable(con, "update_frequency", update_frequency)

#disconnect
dbDisconnect(con)

