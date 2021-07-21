#Script for Data Analysis I
#Update frequency and app success
#Author: Tim Jonathan Rupp
#DISC applied project

rm(list = ls())

#load required packages
library(RSQLite)
library(ggplot2)
library(forcats)
library(reshape2)
library(RColorBrewer)
library(dplyr)
library(psych)
library(ggcorrplot)
library(stringr)
library(mblm)
library(apa)

#connect to db and list tables
con <- dbConnect(SQLite(), "app_reviews.sqlite")

dbListTables(con)

#read app table
data <- dbGetQuery(con, "SELECT * FROM apps;")

#remove unwanted columns
remove <- c(9, 11, 13:16, 18:28, 31:35, 38:40, 42, 44:45, 47:49, 51:60)

data <- data[, -remove]


#convert to factor
data$inAppProductPrice[is.na(data$inAppProductPrice)] <- 0
data$inAppProductPrice[data$inAppProductPrice != 0] <- 1
data$inAppProductPrice <- as.factor(data$inAppProductPrice)

data$editorsChoice <- as.factor(data$editorsChoice)

#add missing info
data$installs[data$app == "evernote"] <- "100,000,000+"
#convert to ordered factor
data$installs <- factor(data$installs, 
                        ordered = TRUE, 
                        levels = c("10,000+", "50,000+", "100,000+",
                                   "500,000+", "1,000,000+", "5,000,000+",
                                   "10,000,000+", "100,000,000+", 
                                   "500,000,000+", "1,000,000,000+", 
                                   "5,000,000,000+"))

#rename columns
colnames(data)[17:18] <- c("n_ratings_store", "n_reviews_store")

#descriptive statistics
summary(data)

#create histograms of relevant variables to see distribution
hist(data$mean_reviews)
hist(data$mean_store)
hist(scale(data$mean_reviews))
hist(scale(data$mean_store))
hist(data$update_frequency, main = "Histogram of Update Frequency", 
     xlab = "Update Frequency (with outliers)")

#boxplot to find update_frequency outliers
boxplot(data$update_frequency)

#find outlier app names
data %>% 
  select(app, update_frequency) %>%
  arrange(desc(update_frequency)) %>%
  top_n(3)

#plot update frequency ~ mean reviews without outliers
data %>%
  filter(app != c("dragonanywhere", "google_analytics")) %>%
  filter(app != c("podio")) %>%
  ggplot(aes(x = update_frequency, y = mean_reviews)) +
  geom_point()

#create subset of data without outliers
data %>%
  filter(app != c("dragonanywhere", "google_analytics")) %>%
  filter(app != c("podio")) -> data3


#plot subset of data
plot(data3$update_frequency, data3$mean_reviews)
hist(data3$update_frequency, main = "Histogram of Update Frequency", 
     xlab = "Update Frequency (no outliers)")
hist(scale(data3$update_frequency))
boxplot(data3$update_frequency)

#get numeric values of installs
data3$installs_total <- data3$installs
data3$installs_total <- str_replace_all(data3$installs_total, ",", "")
data3$installs_total <- str_replace_all(data3$installs_total, "\\+", "")
data3$installs_total <- as.numeric(data3$installs_total)

#create intercorrelation matrix 
cor.mat <- cor(data3[sapply(data3,is.numeric)], method = "spearman")

#create matrix with corresponding p-values
p.mat <- cor_pmat(data3[sapply(data3,is.numeric)], method = "spearman")

#create intercorrelation plot and save
p <- ggcorrplot(cor.mat, hc.order = TRUE,
           type = "lower", p.mat = p.mat)
p
ggsave("intercor.pdf", plot = p, device = "pdf")

#spearman rank correlation of update frequency and app install ranks
cor.test(data3$update_frequency, as.numeric(data3$installs), 
         method = "spearman")

apa(cor.test(data3$update_frequency, as.numeric(data3$installs), 
         method = "spearman"))

#create numeric variable of factor
data3$installs_numeric <- as.numeric(data3$installs)


#Siegel non-parametric regression for update frequency and number of installs
model.k = mblm(installs_total ~ update_frequency,
               data=data3)

#model summary
summary(model.k)

#plot model
plot(installs_total ~ update_frequency,
     data = data3,
     pch  = 16)

#add regression line
abline(model.k,
       col="blue",
       lwd=2)


#calculate 2nd model with numeric factor 
model.k2 = mblm(installs_numeric ~ update_frequency,
               data=data3)

summary(model.k2)

plot(installs_numeric ~ update_frequency,
     data = data3,
     pch  = 16)

abline(model.k2,
       col="blue",
       lwd=2)


#exploratory part:
#plot mean ratings of reviews
data %>%
  mutate(app = fct_reorder(app, mean_reviews)) %>%
  ggplot(aes(x=app, y=mean_reviews)) +
  geom_segment( aes(x=app, xend=app, y=0, yend=mean_reviews), color="skyblue") +
  geom_point( color="red", size=4, alpha=0.6) +
  theme_light() +
  coord_flip() +
  theme(
    panel.grid.major.y = element_blank(),
    panel.border = element_blank(),
    axis.ticks.y = element_blank()
  )

#plot mean ratings of reviews in red and mean ratings of all ratings in blue
data %>%
  group_by(app) %>%
  mutate(min_mean = min(c(mean_store, mean_reviews))) %>%
  mutate(max_mean = max(c(mean_store, mean_reviews))) %>%
  mutate(diff = mean_store - mean_reviews) %>%
  ungroup() %>%
  arrange(desc(app)) %>%
  ggplot(aes(x=app, y=mean_store)) +
  geom_segment( aes(x=app, xend=app, y=0, yend=min_mean), color="grey") +
  geom_segment( aes(x = app, xend = app, 
                    y = min_mean + (diff / 32), yend = max_mean), 
                color = "red") +
  geom_point( color="blue", size=4, alpha=0.8) +
  geom_point(aes(x = app, y = mean_reviews), color = "red", 
             size = 4, alpha = 0.6) +
  theme_light() +
  coord_flip() +
  ylim(0, 5) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.border = element_blank(),
    axis.ticks.y = element_blank()
  ) 


#create subset of ratings for comparing groups
ratings <- data.frame(data$mean_reviews)
names(ratings) <- "mean_reviews"
ratings$mean_store <- data$mean_store

#melt to create groups
ratings <- melt(ratings)

#compare groups
boxplot(value~variable, data=ratings)

#non-parametric test to compare groups (one sided)
wilcox.test(value~variable, 
            data = ratings,
            correct = FALSE,
            conf.int = TRUE,
            alternative = "less")
#review ratings are significantly lower

#compute z and effect size r
z <- qnorm(0.01491)
r <- abs(z/sqrt(40))
r


#plot ordered update frequency
data %>%
  mutate(app = fct_reorder(app, update_frequency)) %>%
  ggplot(aes(x=app, y=update_frequency)) +
  geom_bar(stat="identity", fill="#f68060", alpha=.6, width=.4) +
  coord_flip() +
  xlab("") +
  theme_bw()

#compute number of installs for original data set
data$installs_total <- data$installs
data$installs_total <- str_replace_all(data$installs_total, ",", "")
data$installs_total <- str_replace_all(data$installs_total, "\\+", "")
data$installs_total <- as.numeric(data$installs_total)

#plot number of installs
data %>% 
  mutate(app = fct_reorder(app, installs_total)) %>%
  ggplot(aes(x = app, y = installs_total)) + 
  geom_bar(stat = "identity", fill = "#f68060", alpha = .6, width = .4) +
  coord_flip() +
  xlab("") +
  theme_bw()

#disconnect
dbDisconnect(con)









