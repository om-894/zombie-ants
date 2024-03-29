######################################################################
#                                                                    #
#   The effect of 2 different grooming techniques on the             #
#   prevention of Fungal spore spread in ant colonies.               #
#                                                                    #
######################################################################

######################################################################
#                           Overview                                 #
######################################################################

# The data included in Combined.xlsx is from a NetLogo simulation model assessing  
# two different grooming techniques on preventing the spread of Fungal
# spores. The data measures successful instances of grooming, current population
# and total number of infected ants for both grooming techniques, Allogrooming 
# and selfgrooming.

# The data is organised into six columns, one for Infections when selfgrooming, 
# one for Infections when allogrooming. One for Current population when allogrooming, 
# one for current population when selfgrooming. One for successful grooming instances in 
# allogrooming and one for successful grooming instances when selfgrooming.


######################################################################
#                            Set up                                  #
######################################################################

# Packages to Run
library(tidyverse) 
# for summarising and plotting
# Hadley Wickham (2017). tidyverse: Easily Install and Load the
# 'Tidyverse'. R package version 1.3.2.
# https://CRAN.R-project.org/package=tidyverse

library(readxl)
# for importing excel worksheets
# Hadley Wickham and Jennifer Bryan (2019). readxl: Read Excel
# Files. R package version 1.4.2.
# https://CRAN.R-project.org/package=readxl

library(ggplot2)
# for creating data visualisations
# Wickham H (2016). ggplot2: Elegant Graphics for Data Analysis. 
# R package version 3.4.0
# https://ggplot2.tidyverse.org.


######################################################################
#                    Import and describe data                        #
######################################################################

# Read in the excel data - Excel data is already in Tidy format.
# No need to reformat.
Allo_and_Self <- read_excel("data/Combined.xlsx")

# View the data and check the structure of the data
View(Allo_and_Self)
str(Allo_and_Self)
# tibble [2,001 × 7] (S3: tbl_df/tbl/data.frame)
# $ Time_ticks                         : num [1:2001] 0 10 20 30 40 50 60 70 80 90 ...
# $ Succ_Groom_allo                    : num [1:2001] 0 0 0 0 0 0 0 0 0 0 ...
# $ Current_pop_Allo                   : num [1:2001] 105 105 105 105 105 105 105 105 105 105 ...
# $ Infections_Healed_dead_current_allo: num [1:2001] 0 0 1 1 1 2 3 3 3 3 ...
# $ Succ_groom_self                    : num [1:2001] 0 0 0 0 0 0 0 0 0 0 ...
# $ Current_pop_Self                   : num [1:2001] 105 105 105 105 105 105 105 105 105 105 ...
# $ Infections_Healed_dead_current_self: num [1:2001] 0 0 1 2 2 2 2 2 2 3 ...


######################################################################
#                     Exploratory Analysis                           #
######################################################################

# quick plot of the data
# The data for Allogrooming is represented in the colour "blue"
ggplot() +
  geom_line(data = Allo_and_Self, aes(x = Time_ticks, y = Current_pop_Allo), color = "red") +
  geom_line(data = Allo_and_Self, aes(x = Time_ticks, y = Current_pop_Self), color = "blue")
  
# Overall - both types of grooming appear to show different rates of decline in
# population. The final population in selfgrooming appears to be far lower than
# Allogrooming.

# The data will be separated into Allogrooming and Selfgrooming, in order to analyse
# Both separately.
# Use a poisson GLM for each separate set of data.
# Then use a Chi squared goodness of fit test to test the reduction in deviance to see
# if it is significant.

######################################################################
#                         ALLOGROOMING                               #
######################################################################

# Build a model based on the data using the 'glm()' function and examine the data
# using 'summary()'
amod <- glm(formula = Current_pop_Allo ~ Time_ticks, family = poisson, 
            data = Allo_and_Self)

# What is the Null devience of the response? 
# What is the residual devience of the model?
summary(amod)
# Deviance Residuals: 
# Min        1Q    Median        3Q       Max  
# -0.41337  -0.14065  -0.01091   0.13347   0.50980  

# Coefficients:
#               Estimate Std. Error z value Pr(>|z|)    
# (Intercept)   4.612e+00  5.016e-03   919.4   <2e-16 ***
#  Time_ticks  -5.022e-05  4.979e-07  -100.9   <2e-16 ***
#  ---
#  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# (Dispersion parameter for poisson family taken to be 1)

# Null deviance: 10502.069  on 2000  degrees of freedom
# Residual deviance:    71.826  on 1999  degrees of freedom
# AIC: 11982

# AIC fine on its own, large AIC but nothing to compare it to.
# The Null deviance of the response is 10502.07
# The residual devience of the model is 71.83

exp(amod$coefficients)
#       (Intercept)  Time_ticks 
#       100.6418615   0.9999498 


### WORK OUT CONFIDENCE INTERVALS ###
# Time_ticks
exp(-5.022e-05 - 1.96 * 4.979e-07)
# [1] 0.9999488
exp(-5.022e-05 + 1.96 * 4.979e-07)
# [1] 0.9999508
# The 95% CI on the Time_ticks factor is 0.9999488 - 0.9999508

# (Intercept)
exp(4.612e+00 - 1.96 * 5.016e-03)
# [1] 99.7003
exp(4.612e+00 + 1.96 * 5.016e-03)
# [1] 101.6801
# The 95% CI for the intercept is 99.7003 - 101.6801

# REPORTING
# Our model for Allogrooming predicts that we would obsevre 100.64 
# (95% CI 99.70 - 101.68) ants alive in the current population at less than 1 tick. 
# This number decreases by a factor of 0.9999498 (95% CI 0.9999488 - 0.9999508) 
# for each subsequent tick in the Time in ticks within the NetLogo simulation.


anova(amod, test = "Chisq")
# Analysis of Deviance Table

# Model: poisson, link: log

# Response: Current_pop_Allo

# Terms added sequentially (first to last)


# Df Deviance Resid. Df Resid. Dev  Pr(>Chi)    
# NULL                        2000    10502.1              
# Time_ticks  1    10430      1999       71.8 < 2.2e-16 ***
#  ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# THIS IS A SIGNIFICANT REDUCTION P = 2.2e-16 ***
# The number of ants decreased by a factor of 0.9999498 +/- 1x10^-6 for each tick 
# of the model being run (p < 0.001). On the first tick of the model, a population of 
# 100.64 +/- 1.04 ants is expected.

# NO POST-HOC SINCE THE DATA USES A GLM

# Evaluate wheather the asumptions of the model are met
plot(amod, which = 1)
plot(amod, which = 2)
# These look good and a large sample is used.

# Use predict() to make predictions for a set of sensible values for the explanatory variables
# For example, Use it for Current_pop_Allo
# Create dataframe of thge x values from what i want to predict (every 1000 ticks)
predict_for_Allo <- data.frame(Time_ticks = seq(0, 20000, 1000))
# Add predictions to the dataframe
predict_for_Allo$pred <- predict(amod, newdata = predict_for_Allo, type = "response")

# Create a graph to Show the effects of Allo-grooming, the more successful 
# out of the two grooming techniques, to compare to self grooming on a combined graph.

ggplot(data = Allo_and_Self, aes(x = Time_ticks)) +
  geom_point(aes(y = Current_pop_Allo, 
                 color = "Allo"), 
             size = 1) +
  geom_smooth(aes(y = Current_pop_Allo,
                  color = "Allo"),
              method = "glm", 
              method.args = list(family = "poisson"), 
              se = TRUE, 
              color = "skyblue4", 
              linetype = "solid", 
              size = 1) +
  # GRAPH SCALE (X)
  scale_x_continuous(expand = c(0, 0), 
                     limits = c(0, 21000), 
                     name = "Time (NetLogo ticks)") +
  # GRAPH SCALE (Y)
  scale_y_continuous(expand = c(0, 0), 
                     limits = c(0, 110), 
                     name = "Current population of ants") +
  # Add figure legend in the form of a graph colour key
  scale_color_manual(name = "Grooming Type", 
                     values = c("Allo" = "skyblue"),
                     labels = c("Allo" = "Allo Grooming")) +
  theme_classic()

# Fig 5:GLM using Poisson distribution for Allogrooming model. Predicts we 
# observe 100.64 (95% CI 99.70 - 101.68) ants alive at less than 1 tick. 
# Significant decrease by a factor of 0.9999498 (95% CI 0.9999488 - 0.9999508) 
# for each subsequent tick (p = < 0.001).

# Save the figure to the 'figures' folder to be used within the scientific poster
# Use an appropriate size
ggsave("figures/Allogrooming.png", 
       width = 8, 
       height = 6, 
       units = "in")

######################################################################
#                         SELFGROOMING                               #
######################################################################

# Build a model based on the data using the 'glm()' function and examine the data
# using 'summary()'
smod <- glm(formula = Current_pop_Self ~ Time_ticks, family = poisson, 
            data = Allo_and_Self)

# What is the Null devience of the response? 
# What is the residual devience of the model?
summary(smod)
# The Null deviance of the response 25502.5
# The residual devience of the model is 148.5

# Deviance Residuals: 
#  Min        1Q    Median        3Q       Max  
#-0.61938  -0.19592  -0.00701   0.20382   0.73640  

# Coefficients:
#                Estimate Std. Error z value Pr(>|z|)    
# (Intercept)   4.634e+00  5.454e-03   849.6   <2e-16 ***
#  Time_ticks  -9.463e-05  6.201e-07  -152.6   <2e-16 ***
#  ---
#  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# (Dispersion parameter for poisson family taken to be 1)

# Null deviance: 25502.5  on 2000  degrees of freedom
# Residual deviance:   148.5  on 1999  degrees of freedom
# AIC: 11217

# Number of Fisher Scoring iterations: 3
# AIC fine on its own, large AIC but nothing to compare it to.

exp(smod$coefficients)
# (Intercept)  Time_ticks 
# 102.9073319   0.9999054 

### WORK OUT CONFIDENCE INTERVALS ###
exp(-9.463e-05 + 1.96 * 6.201e-07)
# [1] 0.9999066
exp(-9.463e-05 - 1.96 * 6.201e-07)
# [1] 0.9999042
# The 95% CI on the Time_ticks factor is 0.9999066 - 0.9999042

exp(4.634e+00 - 1.96 * 5.454e-03)
# [1] 101.8306
exp(4.634e+00 + 1.96 * 5.454e-03)
# [1] 104.0311
# The 95% CI for the intercept is 101.83 - 104.03

# Our model for Selfgrooming predicts that we would obsevre 102.91 
# (95% CI 101.83 - 104.03) ants alive in the current population at less than 1 tick. 
# This number decreases by a factor of 0.9999054 (95% CI 0.9999066 - 0.9999042) 
# for each subsequent tick in the Time in ticks within the NetLogo simulation.

# NO POST-HOC SINCE THE DATA USES A GLM

anova(smod, test = "Chisq")
# Analysis of Deviance Table

# Model: poisson, link: log

# Response: Current_pop_Self

# Terms added sequentially (first to last)


# Df Deviance Resid. Df Resid. Dev  Pr(>Chi)    
# NULL                        2000    25502.5              
# Time_ticks  1    25354      1999      148.5 < 2.2e-16 ***
#  ---
#  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# THIS IS A SIGNIFICANT REDUCTION P = 2.2e-16 ***
# The number of ants decreased by a factor of 0.9999054 +/- 1.2x10^-6 for each tick 
# of the model being run (p < 0.001). On the first tick of the model, a population of 
# 101.91 +/- 1.12 ants is expected.

# Evaluate wheather the asumptions of the model are met
plot(smod, which = 1)
plot(smod, which = 2)
# These look good and a large sample is used.

# Use predict() to make predictions for a set of sensible values for the explanatory variables
# For example, Use it for Current_pop_Self
# Create dataframe of the x values from what i want to predict (every 1000 ticks)
predict_for_Self <- data.frame(Time_ticks = seq(0, 20000, 1000))
# Add predictions to the dataframe
predict_for_Self$pred <- predict(smod, newdata = predict_for_Self, type = "response")

# Create a graph to Show the effects of Selfgrooming, the less successful 
# out of the two grooming techniques, to compare to Allogrooming on a combined graph.

ggplot(data = Allo_and_Self, aes(x = Time_ticks)) +
  # SELFGROOMING DISTRIBUTION GLM
  geom_point(aes(y = Current_pop_Self, 
                 color = "Self"), 
             size = 1) +
  geom_smooth(aes(y = Current_pop_Self, 
                  color = "Self"), 
              method = "glm",
              method.args = list(family = "poisson"),
              se = TRUE, 
              color = "orange4", 
              linetype = "solid", 
              size = 1) +
  # GRAPH SCALE (X)
  scale_x_continuous(expand = c(0, 0), 
                     limits = c(0, 21000), 
                     name = "Time (NetLogo ticks)") +
  # GRAPH SCALE (Y)
  scale_y_continuous(expand = c(0, 0), 
                     limits = c(0, 110), 
                     name = "Current population of ants") +
  # Add figure legend in the form of a graph colour key
  scale_color_manual(name = "Grooming Type", 
                     values = c("Self" = "orange"),
                     labels = c("Self" = "Self Grooming")) +
  theme_classic()

# Fig 6:GLM using Poisson distribution for Selfgrooming model. Predicts we 
# would observe 102.91 (95% CI 101.83 - 104.03) ants alive at less than 1 tick. 
# Significant decrease by a factor of 0.9999054 (95% CI 0.9999066 - 0.9999042) 
# for each subsequent tick (p = <0.001).


# Save the figure to the 'figures' folder to be used within the scientific poster
# Use an appropriate size
ggsave("figures/Selfgrooming.png", 
       width = 8, 
       height = 6, 
       units = "in")

######################################################################
#                            Figure                                  #
######################################################################

# Create a plot combining both sets of data for Current_pop for Allo and Self grooming
# Include figure legends

ggplot(data = Allo_and_Self, aes(x = Time_ticks)) +
  # ALLOGROOMING DISTRIBUTION GLM
  geom_point(aes(y = Current_pop_Allo, 
                 color = "Allo"), 
             size = 1) +
  geom_smooth(aes(y = Current_pop_Allo,
                  color = "Allo"),
              method = "glm", 
              method.args = list(family = "poisson"), 
              se = TRUE, 
              color = "skyblue4", 
              linetype = "solid", 
              size = 1) +
  # SELFGROOMING DISTRIBUTION GLM
  geom_point(aes(y = Current_pop_Self, 
                 color = "Self"), 
             size = 1) +
  geom_smooth(aes(y = Current_pop_Self, 
                  color = "Self"), 
              method = "glm",
              method.args = list(family = "poisson"),
              se = TRUE, 
              color = "orange4", 
              linetype = "solid", 
              size = 1) +
  # GRAPH SCALE (X)
  scale_x_continuous(expand = c(0, 0), 
                     limits = c(0, 21000), 
                     name = "Time (NetLogo ticks)") +
  # GRAPH SCALE (Y)
  scale_y_continuous(expand = c(0, 0), 
                     limits = c(0, 110), 
                     name = "Current population of ants") +
  # Add figure legend in the form of a graph colour key
  scale_color_manual(name = "Grooming Type", 
                     values = c("Allo" = "skyblue", "Self" = "orange"),
                     labels = c("Allo" = "Allo Grooming", "Self" = "Self Grooming")) +
  theme_classic()

# Fig 7:Comparison in rates of population decline between Allogrooming and 
# Selfgrooming using generalized linear models for both grooming techniques 
# and plotted together. 

# Save the figure to the 'figures' folder to be used within the scientific poster
# Use an appropriate size
ggsave("figures/Allo and Self.png", 
       width = 8, 
       height = 6, 
       units = "in")

######################################################################
#                       END OF ANALYSIS                              #
######################################################################


