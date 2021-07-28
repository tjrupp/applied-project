#Script for Data Analysis II
#Topic modelling and update content
#Author: Tim Jonathan Rupp
#DISC applied project

rm(list = ls())

#load required packages
library(dplyr)
library(writexl)
library(ggcorrplot)
library(apa)
library(psychometric)

#connect to database and load data
con <- dbConnect(SQLite(), "app_reviews.sqlite")

dbListTables(con)

LDA_reviews <- dbGetQuery(con, "SELECT * FROM LDA_reviews3;")

reviews <-dbGetQuery(con, "SELECT * FROM reviews;")

LDA_patchnotes <- dbGetQuery(con, "SELECT * FROM LDA_patchnotes;")

patchnotes <- dbGetQuery(con, "SELECT * FROM patchnotes;")

#set index +1 and rename column
LDA_reviews$index <- LDA_reviews$index + 1
names(LDA_reviews)[1] <- "ID"

#join review table and review Topics
reviews <- left_join(reviews, LDA_reviews, by = "ID")

#set patchnote Topics index +1
LDA_patchnotes$index <- LDA_patchnotes$index + 1

#add index to patchnote table
patchnotes$index <- 1:length(patchnotes$version)

#join patchnotes table with LDA Topics
patchnotes <- left_join(patchnotes, LDA_patchnotes, by = "index")

#get topwords for each topic of review LDA
topics <- dbGetQuery(con, "SELECT * FROM LDA_reviews_topwords3;")
topics$`0` <- NULL
topics$index <- topics$index + 1
names(topics)[2] <- "topwords"

#write to excel for easier reading
#write_xlsx(topics, "topics_reviews.xlsx")

#get patchnote topwords and save to excel
topics_patchnotes <- dbGetQuery(con, "SELECT * FROM LDA_patchnotes_topwords;")
topics_patchnotes$`0` <- NULL
topics_patchnotes$index <- topics_patchnotes$index + 1
names(topics_patchnotes)[2] <- "topwords"

#write_xlsx(topics_patchnotes, "topics_patchnotes.xlsx")

#rename Topics +1 (Python starts counting from 0)
names(reviews)[16:21] <- paste0("Topic_", 1:6)


#correlation matrix of score, sentiment and review Topics
subset_cor <- reviews[, c("score", "ave_sentiment", paste0("Topic_", 1:6))]
cor.mat <- cor(subset_cor, method = "pearson")

p.mat <- cor_pmat(subset_cor, method = "pearson")

p <- ggcorrplot(cor.mat, hc.order = TRUE,
              type = "lower", p.mat = p.mat)
p

#save matrix as pdf
ggsave("reviews_topics_all.pdf", p, device = "pdf")

#create subset of first 1000 to test consistency
subset2 <- subset_cor[1:1000, ]

cor.mat <- cor(subset2, method = "pearson")

p.mat <- cor_pmat(subset2, method = "pearson")

p <- ggcorrplot(cor.mat, hc.order = TRUE,
                type = "lower", p.mat = p.mat)
p

#create random subsets of 100 to test consistency
subset3 <- subset_cor[sample(1:3185528, 100), ]

cor.mat <- cor(subset3, method = "pearson")

p.mat <- cor_pmat(subset3, method = "pearson")

p <- ggcorrplot(cor.mat, hc.order = TRUE,
                type = "lower", p.mat = p.mat)
p


#compute 10000 random subsamples 
list <- list()

for (i in 1:10000) {
  subset4 <- subset_cor[sample(1:3185528, 100), ]
  a <- cor.test(subset4$score, subset4$Topic_1)
  b <- cor.test(subset4$score, subset4$Topic_4)
  c <- cor.test(subset4$ave_sentiment, subset4$Topic_1)
  d <- cor.test(subset4$ave_sentiment, subset4$Topic_4)
  e <- list(a, b, c, d)
  list[[i]] <- e
}

#compute correlations on the subsamples and print mean 
#correlation, mean significance and number of times the 
#correlation test was significant
a <- 0
b <- 0
c <- 0
for (i in seq_along(list)) {
a <- a + as.numeric(list[[i]][[1]]$estimate)
b <- b + as.numeric(list[[i]][[1]]$p.value)
if(as.numeric(list[[i]][[1]]$p.value) < .05) {c <- c + 1}
if(i == 10000) {
  print("score ~ topic1")
  print(paste0("mean r: ", a / 10000))
  print(paste0("mean p: ", b / 10000))
  print(paste0("no. significant: ", c))
 }
}

#compute correlations on the subsamples and print mean 
#correlation, mean significance and number of times the 
#correlation test was significant
a <- 0
b <- 0
c <- 0
for (i in seq_along(list)) {
  a <- a + as.numeric(list[[i]][[2]]$estimate)
  b <- b + as.numeric(list[[i]][[2]]$p.value)
  if(as.numeric(list[[i]][[2]]$p.value) < .05) {c <- c + 1}
  if(i == 10000) {
    print("score ~ topic4")
    print(paste0("mean r: ", a / 10000))
    print(paste0("mean p: ", b / 10000))
    print(paste0("no. significant: ", c))
  }
}

#compute correlations on the subsamples and print mean 
#correlation, mean significance and number of times the 
#correlation test was significant
a <- 0
b <- 0
c <- 0
for (i in seq_along(list)) {
  a <- a + as.numeric(list[[i]][[3]]$estimate)
  b <- b + as.numeric(list[[i]][[3]]$p.value)
  if(as.numeric(list[[i]][[3]]$p.value) < .05) {c <- c + 1}
  if(i == 10000) {
    print("sentiment ~ topic1")
    print(paste0("mean r: ", a / 10000))
    print(paste0("mean p: ", b / 10000))
    print(paste0("no. significant: ", c))
  }
}

#compute correlations on the subsamples and print mean 
#correlation, mean significance and number of times the 
#correlation test was significant
a <- 0
b <- 0
c <- 0
for (i in seq_along(list)) {
  a <- a + as.numeric(list[[i]][[4]]$estimate)
  b <- b + as.numeric(list[[i]][[4]]$p.value)
  if(as.numeric(list[[i]][[4]]$p.value) < .05) {c <- c + 1}
  if(i == 10000) {
    print("sentiment ~ topic4")
    print(paste0("mean r: ", a / 10000))
    print(paste0("mean p: ", b / 10000))
    print(paste0("no. significant: ", c))
  }
}

#compute correlations and get proper output
apa(cor.test(subset_cor$Topic_4, subset_cor$ave_sentiment))
apa(cor.test(subset_cor$Topic_4, subset_cor$score))
apa(cor.test(subset_cor$Topic_1, subset_cor$ave_sentiment))
apa(cor.test(subset_cor$Topic_1, subset_cor$score))

#compute confidence intervals 
CIr(r = .42, n = 3185526, level = .99)
CIr(r = .19, n = 3185526, level = .99)
CIr(r = -.37, n = 3185526, level = .99)
CIr(r = -.31, n = 3185526, level = .99)

#rename patchnote topics
names(patchnotes)[6:9] <- paste0("Topic_", as.numeric(names(patchnotes)[6:9])+1)

#save top 10 reviews for each topic
top_reviews1 <- reviews %>% 
  dplyr::select(content, app, Topic_1) %>%
  #group_by(app) %>% 
  arrange(Topic_1) %>%
  top_n(10) 

top_reviews2 <- reviews %>% 
  dplyr::select(content, app, Topic_2) %>%
  #group_by(app) %>% 
  arrange(Topic_2) %>%
  top_n(10) 

top_reviews3 <- reviews %>% 
  dplyr::select(content, app, Topic_3) %>%
  #group_by(app) %>% 
  arrange(Topic_3) %>%
  top_n(10) 

top_reviews4 <- reviews %>% 
  dplyr::select(content, app, Topic_4) %>%
  #group_by(app) %>% 
  arrange(Topic_4) %>%
  top_n(500) 

top_reviews5 <- reviews %>% 
  dplyr::select(content, app, Topic_5) %>%
  #group_by(app) %>% 
  arrange(Topic_5) %>%
  top_n(10) 

top_reviews6 <- reviews %>% 
  dplyr::select(content, app, Topic_6) %>%
  #group_by(app) %>% 
  arrange(Topic_6) %>%
  top_n(10) 


#save top ten patchnotes for each topic
top_patchnotes1 <- patchnotes %>%
  dplyr::select(content, app, Topic_1) %>%
  arrange(Topic_1) %>% 
  top_n(10)

top_patchnotes2 <- patchnotes %>%
  dplyr::select(content, app, Topic_2) %>%
  arrange(Topic_2) %>% 
  top_n(10)

top_patchnotes3 <- patchnotes %>%
  dplyr::select(content, app, Topic_3) %>%
  arrange(Topic_3) %>% 
  top_n(10)

top_patchnotes4 <- patchnotes %>%
  dplyr::select(content, app, Topic_4) %>%
  arrange(Topic_4) %>% 
  top_n(10)

#compute mean topic values for each app
patchnotes %>%
  dplyr::select(app, Topic_1, Topic_2, Topic_3, Topic_4) %>%
  group_by(app) %>%
  summarise(Topic_1mean = mean(Topic_1), Topic_2mean = mean(Topic_2),
            Topic3_mean = mean(Topic_3), Topic_4mean = mean(Topic_4)) ->
  mean_patchnotes

apps <- dbGetQuery(con, "SELECT * FROM apps")

#merge with mean review scores and mean store score
mean_patchnotes$mean_reviews <- apps$mean_reviews
mean_patchnotes$mean_store <- apps$mean_store
mean_patchnotes$mean_sentiment <- apps$mean_sentiment

#compute intercorrelation matrix of mean Topic values and ratings with
#patchnote topics
cor.mat <- cor(mean_patchnotes[, 2:8], method = "pearson")

p.mat <- cor_pmat(mean_patchnotes[, 2:8], method = "pearson")

p <- ggcorrplot(cor.mat, hc.order = TRUE,
                type = "lower", p.mat = p.mat)
p

#save matrix
ggsave("patchnotes_topics.pdf", p, device = "pdf")


#compute mean Topic values per app
reviews %>%
  select(app, Topic_1, Topic_2, Topic_3, Topic_4, Topic_5, Topic_6) %>%
  group_by(app) %>%
  summarise(Topic_1mean = mean(Topic_1), Topic_2mean = mean(Topic_2),
            Topic_3mean = mean(Topic_3), Topic_4mean = mean(Topic_4),
            Topic_5mean = mean(Topic_5), Topic_6mean = mean(Topic_6)) ->
  mean_reviews

#merge with app review rating and store rating
mean_reviews$mean_reviews <- apps$mean_reviews
mean_reviews$mean_store <- apps$mean_store
mean_reviews$mean_sentiment <- apps$mean_sentiment
#intercorrelation matrix for review topics and ratings
cor.mat <- cor(mean_reviews[, 2:10], method = "pearson")

p.mat <- cor_pmat(mean_reviews[, 2:10], method = "pearson")

p <- ggcorrplot(cor.mat, hc.order = TRUE,
                type = "lower", p.mat = p.mat)
p

ggsave("reviews_topics.pdf", p, device = "pdf")


#list of topword data frames
list <- list(top_patchnotes1, top_patchnotes2, top_patchnotes3, top_patchnotes4,
             top_reviews1, top_reviews2, top_reviews3, top_reviews4, 
             top_reviews5, top_reviews6)

#names for writing excel files
names <- c("top_patchnotes1", "top_patchnotes2", "top_patchnotes3", 
           "top_patchnotes4", "top_reviews1", "top_reviews2", "top_reviews3", 
           "top_reviews4", "top_reviews5", "top_reviews6")

#loop for writing excel files for each topword object for easier exploring
#for (i in seq_along(list)) {
#  write_xlsx(list[[i]], paste0(names[i], ".xlsx"))
#}


       