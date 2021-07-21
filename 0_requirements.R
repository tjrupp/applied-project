#Script for installing and loading all required r-packages
#and creating needed folders
#Author: Tim Jonathan Rupp
#DISC applied project

#install pacman for easily installing the other needed packages
install.packages("pacman")
library(pacman)

#if not installed, install packages, if installed just load
p_load("stringr", "jsonlite", "dplyr", "RSQLite", "readr", "sentimentr",
         "forcats", "reshape2", "RColorBrewer", "psych", "ggcorrplot",
         "mblm", "apa")

#create folder for scraping app details
dir.create("app_JSON")

#create folder for scraping app reviews
dir.create("reviews_JSON")

