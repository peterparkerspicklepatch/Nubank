# Goal
The challenge was to predict assign prediction scores based on the values from the test set. The train data package contains the dependent variable, target. All of the variables as well as observations are hashed. How do you build a model to predict something you don't know using data you know? Also consider there are over 200 varaibles, some categorical and some numerical. 

Given this I choose to, 
    + Employ a variable section method (LASSO regression) to pick-out variables 
    + Pre-Process the dependent variable using a simple power transformation 
    + …and then employ an OLS model with the non-zero variables from the LASSO Regression

## Results
Given the in – sample all variable linear model produced an R2 of .7381, it will be impossible to do better then that out of sample. My model produced an R2 of about .6271, a .111 drop. If we’re using adjusted-R2 the difference was smaller, .1016. These results are encouraging considering my model has about 40% less variables when compared to the all linear model (if you change the categorical to dummies).  Given this, I would expect my out-of-sample R2 to be above .40. As a side note, I would never use R2 to judge the validity of a model. Sometimes a high R2 can even be bad (overfitting) and the ‘explanation’ of variance is not always the purpose of the model. The goal of the exersize, however, was to maximize the out-of-sample R2.  
