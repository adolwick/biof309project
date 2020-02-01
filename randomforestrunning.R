### Running Through Random Forests

##### Setup #####
library(tidyverse)
library(ggplot2)
library(scales)
library(RColorBrewer)
library(randomForest)
require(caTools)
setwd("~/dolwick_project")
r_data <- read_csv("clean.csv")

##### Attempt No. 1 (aka Model A) -- without runtime #####
runs <- r_data[,-3] %>%
  filter(!is.na(pace_min))

sample_run = sample.split(runs$pace_min, SplitRatio = .75)
training = subset(runs, sample_run == TRUE)
testing  = subset(runs, sample_run == FALSE)

rf_run <- randomForest(
  pace_min ~ .,
  data=training,
  importance=TRUE
)
rf_run
#looks like it ran a regression and explained 48% of the variance
  #in the OOP data
print(rf_run$ntree)
  #number of decision trees = 500 (this is default)
print(rf_run$mse)
  #final mse = .45 (higher is worse)
#output showing importance of each feature
print(rf_run$importance)
#           %IncMSE IncNodePurity
# Date    0.4253743      460.3396
# Mileage 0.7311216      588.0173
# higher %IncMSE = more important variable
# for more info on interpreting these data:
  # https://stats.stackexchange.com/questions/162465/in-a-random-forest-is-larger-incmse-better-or-worse


#predicting the pace of my runs I think lol
pred_run = predict(rf_run, newdata=testing[-3])

#looking at the predicted values of each run in the test sample
testingpred <- testing
testingpred$pred <- pred_run

##### Attempt No. 2 (aka Model B) -- with runtime #####
r_data2 <- r_data %>%
  separate(time_corr, c("h", "m", "s"), sep = ":") %>%
  filter(!is.na(pace_min))

r_data2$h <- as.numeric(r_data2$h)
r_data2$m <- as.numeric(r_data2$m)
r_data2$s <- as.numeric(r_data2$s)

runs2 <- r_data2 %>%
  mutate(runtime_min = 60*h + m + s/60) %>%
  select(1,2,7,6)

sample_run2 = sample.split(runs2$pace_min, SplitRatio = .75)
training2 = subset(runs2, sample_run == TRUE)
testing2  = subset(runs2, sample_run == FALSE)

rf_run2 <- randomForest(
  pace_min ~ .,
  data=training2,
  importance=TRUE
)
rf_run2
  #80.97% var explained ... WAY better than last time
print(rf_run2$mse)
  #final mse = .16 ... WAY better than last time
print(rf_run2$importance)
# the runtime variable was unsurprisingly hugely important
# mileage was also very important, which also makes sense

#predicting the pace of my runs
pred_run2 = predict(rf_run2, newdata=testing2[-4])

#looking at the predicted values of each run in the test sample
testingpred2 <- testing2
testingpred2$pred_w_time <- pred_run2

##### Comparing the Two Models #####
compare <- full_join(testingpred, testingpred2)
compare <- compare %>% select(1:2,5,3:4,6)

colnames(compare)[4] <- "actual_pace"
colnames(compare)[5] <- "rfpred_pace"
colnames(compare)[6] <- "rfpred_pace_w_time"

compared <- compare %>%
  mutate(wo_time_error = abs(rfpred_pace - actual_pace)) %>%
  mutate(w_time_error = abs(rfpred_pace_w_time - actual_pace)) %>%
  mutate(time_model_improve = wo_time_error - w_time_error)

##### Graphing the Model Comparisons #####
hist(compared$time_model_improve)

myPalette <- colorRampPalette(brewer.pal(11, "Spectral"))
sc <- scale_colour_gradientn(colors = myPalette(100), limits=c(4, 10))

ggplot(data = compared) + 
  geom_point(mapping = aes(x = Date, y = time_model_improve,
                           color = actual_pace)) + 
  sc +
  theme_dark() +
  scale_x_date(breaks = "years", date_labels = "20%y") +
  scale_y_continuous(name = "Accuracy of Model B compared to A (min/mi)",
                     breaks = c(-0.5,0,0.5,1,1.5,2), 
                     labels = c(-0.5,0,0.5,1,1.5,2),
                     limits = c(-0.5,2)) +
  ggtitle("Accuracy of Model B (w/ run time) over Model A (w/o run time) ")


compared_A <- compared %>%
  separate(Date, c("year", "month", "day"), sep = "-")

ggplot(data = compared_A) + 
  geom_point(mapping = aes(x = Mileage, y = time_model_improve,
                           color = year)) +
  scale_x_continuous(name = "Distance (mi)",
                     breaks = c(0,2,4,6,8,10,12,14,16,18), 
                     labels = c(0,2,4,6,8,10,12,14,16,18),
                     limits = c(0.5,18.5)) +
  scale_y_continuous(name = "Accuracy of Model B compared to A (min/mi)",
                     breaks = c(-0.5,0,0.5,1,1.5,2), 
                     labels = c(-0.5,0,0.5,1,1.5,2),
                     limits = c(-0.5,2)) +
  ggtitle("Accuracy of Model B (w/ run time) over Model A (w/o run time) ")









