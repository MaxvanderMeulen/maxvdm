#step 5

#Load libraries
library(carData)
library(ggplot2)
library(dplyr)
library(broom)

combined_mean_data1 <- read.csv("../../gen/input/combined_mean_data.csv")
private_room <- read.csv("../../gen/input/private_room.csv")
dir.create("../../gen/output/")

#plot the mean prices. As you can see the price in dublin is the highest, and in manchester the lowest.

ggplot(combined_mean_data1, aes(x= city, y=mean_price, color = city)) +
  geom_point() 
ggsave("../../gen/output/mean_price.pdf")

#plot the mean reviews per city. As you can see the highest score is in edinburgh, the lowest is in barcelona

ggplot(combined_mean_data1, aes(x= city, y=mean_reviews1, color = city)) +geom_point()
ggsave("../../gen/output/mean_reviews.pdf")

#plot the mean availability per city. 

ggplot(combined_mean_data1, aes(x= city, y=mean_availability, color = city)) +geom_point()
ggsave("../../gen/output/mean_availability.pdf")


##Step 6
#######

library(effects)
library(carData)
library(ggplot2)
library(dplyr)
library(broom)

#Check if price and reviews have a relationship
sink("../../gen/output/price_regression.txt") 
reg1 <- lm(review_scores_rating ~ price, data = private_room)
summary(reg1)
sink()

#check if reviews and availability have a relationship
sink("../../gen/output/availability_regression.txt") 
reg2 <- lm(review_scores_rating ~ availability_365, data = private_room)
summary(reg2)
sink()

#regression with multiple variables
sink("../../gen/output/multiple_regression.txt") 
regression <- lm(review_scores_rating ~ price + availability_365 + short_stay +city, data=private_room)
summary(regression)
sink()

#plot of our regression model

pdf("../../gen/output/multiple_regression.pdf") 
plot <- plot(allEffects(regression), ylim={c(4.5, 5)})
dev.off()

#Calculate the finale score of the  cities based on the regression

final_score<-summary(regression)$coefficients[1,1]+summary(regression)$coefficients[2,1]*combined_mean_data1$mean_price[2:10]+summary(regression)$coefficients[3,1]*combined_mean_data1$mean_availability[2:10]+summary(regression)$coefficients[4,1]+summary(regression)$coefficients[5:13,1] 
final_score <-as.data.frame(final_score)

#As Barcelona is the 'base coefficient' we need to add this one seperately

citybarcelona <- summary(regression)$coefficients[1,1]+summary(regression)$coefficients[2,1]*combined_mean_data1$mean_price[1]+summary(regression)$coefficients[3,1]*combined_mean_data1$mean_availability[1]+summary(regression)$coefficients[4,1] 
final_score[nrow(final_score) + 1,] = citybarcelona

#changing the row names

rownames(final_score) <- c("berlin", "copenhagen", "dublin", "edinburgh", "london", "manchester", "munich", "paris", "vienna", "barcelona")
names(final_score)[1]<-"score"

#Rounding the final review scores
final_score<- final_score %>%
  mutate_if(is.numeric, round, digits =3)
final_score<- final_score %>% arrange(desc(score))

write.csv(final_score, "../../gen/output/final_score.csv")
