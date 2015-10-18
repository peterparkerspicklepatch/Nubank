#install multiple packages
#code by https://gist.github.com/stevenworthington/3178163#file-ipak-r
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

packages <- c("ggplot2","glmnet", "pastecs", "glmnet", "lars")
ipak(packages)

#set import location
setwd(dir = "/home/rstudio/Nubank")

#import data
nubank_train <- read.csv('train.csv' , header = T)
nubank_test <- read.csv('test.csv', header = T)
nubank_train_no_target <- nubank_train[c(1:106)]

#check out data, check if hashes are categorical variables
str(nubank_train)
summary(nubank_train)

#check out y variable
library(ggplot2); library(pastecs)
qplot(nubank_train$target)
stat.desc(nubank_train$target)

#Preliminary results show dependent variable is not a standard normal. Does a simple power transformation help? 
#Going to save this for later.
qplot(nubank_train$target^(1/4))

#Lots of unimporant predictors. Parsimonious models are great. I'm going to use LASSO regression.

#Seperate focator and numerical variables
is.fact <- sapply(nubank_train_no_target, is.factor)
factors.df <- nubank_train_no_target[, is.fact]

is.num <- sapply(nubank_train_no_target, is.numeric)
num.df <- nubank_train_no_target[, is.num]

#final prep for LASSO
y <- as.numeric(nubank_train$target)
xfactors <- model.matrix(y ~ -1 + . , data=factors.df, contrasts.arg = lapply(factors.df, contrasts, contrasts=FALSE))
x <- as.matrix(data.frame(num.df, xfactors))

#run regression
library(glmnet)
lasso <- glmnet(x, y)
summary(lasso)

#plot coefficents
plot(lasso)

#select lambda with lowest error using cross validation
cvlasso <- cv.glmnet(x, y)
plot(cvlasso)

cvlasso$lambda.min
coef(cvlasso, s = "lambda.min")

#select variables with non - zero coefficents
variables <- as.character(colnames(x)[which(coef(cvlasso, s = "lambda.min") != 0)])

#select LASSO dummies 
filtered.df <- x[,variables]
filtered.df <- data.frame(filtered.df)

#Incorporate into model former power transformaiton into model
nubank_train$target <- nubank_train$target^(1/4)

#Now I'm going to run an OLS with the non- zero variables from LASSO
linear <- lm(nubank_train$target ~ ., data = filtered.df)
summary(linear)

#compare with all linear model
linear_all <- lm(nubank_train$target ~ ., data = nubank_train_no_target)
summary(linear_all)

#check to see if the models are statistically different
anova(linear, linear_all, test = "Chisq")

# Function that returns Root Mean Squared Error and MBE, important to check out
#Credit: https://heuristically.wordpress.com/2013/07/12/calculate-rmse-and-mae-in-r-and-sas/
rmse <- function(error)
{
  sqrt(mean(error^2))
}
mae <- function(error)
{
  mean(abs(error))
}

rmse(linear$residuals)
rmse(linear_all$residuals)
mae(linear$residuals)
mae(linear_all$residuals)

#prepare test set for prediction using same method as before
is.fact.test <- sapply(nubank_test, is.factor)
factors.df.test <- nubank_test[, is.fact]
is.num.test<- sapply(nubank_test, is.numeric)
num.df.test <- nubank_test[, is.num]
xfactors.test <- model.matrix(~ -1 + . , data=factors.df.test, contrasts.arg = lapply(factors.df.test, contrasts, contrasts=FALSE))
nubank_test_prediction <- data.frame(num.df.test, xfactors.test)

#...as well as selecting the variables from LASSO
nubank_test_prediction <- nubank_test_prediction[,variables]

#predict new values
scores <- data.frame(predict(linear, nubank_test_prediction, type = 'response'))
scores$id <- 24976:49951 

#apply inverse of pre-process from before to the predictions
scores$predict.linear..nubank_test_prediction..type....response..pr <- scores$predict.linear..nubank_test_prediction..type....response..^4

#take a final look
qplot(scores$predict.linear..nubank_test_prediction..type....response..)
#....and write scores
write.csv(scores, header = T)


