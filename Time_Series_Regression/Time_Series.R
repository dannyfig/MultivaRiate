# Author: Danny Vilela
# Date: 13 April 2016
#   This script will serve to clean, validate, and filter the values 
#   that are relevant for the multiple linear regression task.

# Define required packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load("car", "dplyr", "ggplot2", "lmtest", "leaps", "sme", "lawstat")

## SETUP I/O

# Read in our Yahoo Finance and Google trend datasets
tesla_data <- read.csv("tesla.csv", header = TRUE)
google_trends_data <- read.csv("tesla_goog.csv", header = TRUE)

## DATA VALIDATION / CLEANING UP

# Remove null columns
google_trends_data <- select(google_trends_data, -X, -X.1, -X.2, -X.3, -X.4, -X.5)

# Remove null rows
google_trends_data <- slice(google_trends_data, 1:dim(tesla_data)[1])

# Treat our dates as Date format
google_trends_data$Date <- as.Date(google_trends_data$Date, "%m/%d/%y")
tesla_data$Date <- as.Date(tesla_data$Date, "%m/%d/%y")

# Order our Date fields for 1:1 joining
google_trends_data[order(google_trends_data$Date), ]
tesla_data[order(tesla_data$Date), ]

# Join our trends data into our tesla dataframe
tesla_data$Search.Interest <- google_trends_data$interest

# Remove adjusted close price
tesla_data <- select(tesla_data, -Adj.Close)

# Scale our Volume field such that it is on the order of million
tesla_data$Volume <- tesla_data$Volume / 1000000 

# Split our dataset into a working and validation sets
# tesla_validation_set <- slice(tesla_data, 1:40)
# tesla_data <- slice(tesla_data, 41:302)

# Log our target variable since it's money data and right-tailed
tesla_data$log.High <- log10(tesla_data$High)
# tesla_validation_set$log.High <- log10(tesla_validation_set$High)

## Exploratory

# Quick summary of our dataset
summary(tesla_data)

# Open device for saving plot
png(filename = "scatter_matrix.png",
    width = 1000, height = 1000, units = "px",
    res = 130)

# Plot all pairs 
pairs(~log.High + Open + Close + Volume + Search.Interest, 
      data = tesla_data, main = "Linear Correlation Plots")

# Close our PNG filewriter
dev.off()

# Determine correlation values between each of our predictors
# Output to standard output
cor(cbind(tesla_data$log.High, tesla_data$Open, tesla_data$Close, tesla_data$Volume, tesla_data$Search.Interest))

# Open device for saving plot
png(filename = "histogram_of_high.png",
    width = 1000, height = 700, units = "px",
    res = 120)

# Histogram of raw stock High value
ggplot(tesla_data, aes(High)) + geom_histogram() + 
  xlab("Stock High") + ylab("Frequency")

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "date_vs_high.png", 
    width = 1500, height = 700, units = "px",
    res = 120)

# Basic scatterplot of stock price high over time
qplot(x = tesla_data$Date, y = tesla_data$log.High, geom = "point",
      xlab = "Date", ylab = "Log Stock High")

# Close our PNG filewriter
dev.off()

## Regression

# Store our regression
tesla_regression <- lm(tesla_data$log.High ~ tesla_data$Open +
                         tesla_data$Close + tesla_data$Volume +
                         tesla_data$Search.Interest)

# Output a summary of our regression data
summary(tesla_regression)

# Get collinearity coefficients
vif(tesla_regression)

# Get standard residuals from our regression
stdres <- rstandard(tesla_regression)

# Open device for saving plot
png(filename = "fitted_vs_stdres.png", 
    width = 700, height = 700, units = "px",
    res = 120)

# Plot our fitted values against the standardized residuals
# "Versus Fits"
plot(fitted(tesla_regression), stdres, 
     xlab = "Fitted values", ylab = "Standardized residuals",
     main = "Versus Fits")

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "stdres_vs_qq_percent.png", 
    width = 700, height = 700, units = "px",
    res = 120)

# Plot our Normal Probability
qqnorm(stdres, xlab = "Standardized Residual",
       main = "Normal Probability Plot")

# Close our PNG filewriter
dev.off()

# Cooks distance diagnostics
cbind(stdres, hatvalues(tesla_regression), cooks.distance(tesla_regression))

# Open device for saving plot
png(filename = "date_vs_standardized_residuals.png", 
    width = 1500, height = 600, units = "px",
    res = 120)

# Plot standardized residuals -- observe nc variance
plot(tesla_data$Date, stdres, 
     ylab = "Standardized residuals", xlab = "Date (Observation Order)",
     main = "Versus Order") + lines(tesla_data$Date, stdres)

# Close our PNG filewriter
dev.off()

# Calculate Durbin-Watson statistic
dwtest(tesla_data$log.High ~ tesla_data$Open +
         tesla_data$Close + tesla_data$Volume +
         tesla_data$Search.Interest)

# z-statistic using s, Cook's distance
cbind(stdres, hatvalues(tesla_regression), cooks.distance(tesla_regression))

## Best subsets
leaps(cbind(tesla_data$Open, tesla_data$Close, tesla_data$Volume, tesla_data$Search.Interest), tesla_data$log.High, nbest = 2)
leaps(cbind(tesla_data$Open, tesla_data$Close, tesla_data$Volume, tesla_data$Search.Interest), tesla_data$log.High, nbest = 2, method = "adjr2")
leaps(cbind(tesla_data$Open, tesla_data$Close, tesla_data$Volume, tesla_data$Search.Interest), tesla_data$log.High, nbest = 2, method = "r2")

# Get s for all proposed subset models...the hard way
# Repeat until you've done the best subsets reported above
reg_1_1 <- lm(tesla_data$log.High ~ tesla_data$Close)
reg_1_2 <- lm(tesla_data$log.High ~ tesla_data$Open)
reg_2_1 <- lm(tesla_data$log.High ~ tesla_data$Close + tesla_data$Volume)
reg_2_2 <- lm(tesla_data$log.High ~ tesla_data$Open + tesla_data$Volume)
# omit reg_3_1 because of collinearity
reg_3_2 <- lm(tesla_data$log.High ~ tesla_data$Close + tesla_data$Volume +
                tesla_data$Search.Interest)
reg_4_1 <- lm(tesla_data$log.High ~ tesla_data$Open +
                tesla_data$Close + tesla_data$Volume +
                tesla_data$Search.Interest)
# ...
# We find o

# Akaike information criterion for our model
AIC(reg_1_1)
AIC(reg_1_2)
AIC(reg_2_1)
AIC(reg_2_2)
AIC(reg_3_2)

# Corrected AIC for our model
AICc(reg_1_1)
AICc(reg_1_2)
AICc(reg_2_1)
AICc(reg_2_2)
AICc(reg_3_2)

# Woo! We go with reg_2_1, which has predictors Close and Volume
# Let's plot the scatterplot matrix of predictors

# Open device for saving plot
png(filename = "scatter_matrix_redux.png",
    width = 1000, height = 1000, units = "px",
    res = 130)

# Plot all pairs 
pairs(~log.High + Close + Volume, data = tesla_data, main = "Linear Correlation Plots: Redux")

# Close our PNG filewriter
dev.off()

redux_regression <- lm(tesla_data$log.High ~ tesla_data$Close + tesla_data$Volume)

summary(redux_regression)

vif(redux_regression)

## Residuals redux

redux_stdres <- rstandard(redux_regression)

# Open device for saving plot
png(filename = "fitted_vs_stdres_redux.png", 
    width = 700, height = 700, units = "px",
    res = 120)

# Plot our fitted values against the standardized residuals
# "Versus Fits"
plot(fitted(redux_regression), redux_stdres, 
     xlab = "Fitted values", ylab = "Standardized residuals",
     main = "Versus Fits")

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "stdres_vs_qq_percent_redux.png", 
    width = 700, height = 700, units = "px",
    res = 120)

# Plot our Normal Probability
qqnorm(redux_stdres, xlab = "Standardized Residual",
       main = "Normal Probability Plot")

# Close our PNG filewriter
dev.off()

# Cooks distance diagnostics
cbind(redux_stdres, hatvalues(redux_regression), cooks.distance(redux_regression))

# Open device for saving plot
png(filename = "date_vs_standardized_residuals_redux.png", 
    width = 1500, height = 600, units = "px",
    res = 120)

# Plot standardized residuals -- observe nc variance
plot(tesla_data$Date, redux_stdres, 
     ylab = "Standardized residuals", xlab = "Date (Observation Order)",
     main = "Versus Order") + lines(tesla_data$Date, redux_stdres)

# Close our PNG filewriter
dev.off()

# Calculate Durbin-Watson statistic
dwtest(tesla_data$log.High ~ tesla_data$Close + tesla_data$Volume)

# Open device for saving ACF plot
png(filename = "acf_redux.png", 
    width = 1500, height = 600, units = "px",
    res = 120)

# Plot standardized residuals -- observe nc variance
acf(redux_stdres, xlab = "Lag", ylab = "Autocorrelation", 
    ci = 0.95, ci.type = "ma", main = "Autocorrelation function for SRE", 
    ci.col = "red", verbose = TRUE)

# Close our PNG filewriter
dev.off()

# Perform Runs test
runs.test(redux_stdres)

# Initialize time column
tesla_data$Time = 1:dim(tesla_data)[1]

# Open device for saving plot
png(filename = "time_vs_high_redux.png", 
    width = 1500, height = 700, units = "px",
    res = 120)

# Basic scatterplot of stock price high over time, but this time with time column
qplot(x = tesla_data$Time, y = tesla_data$log.High, geom = "point",
      xlab = "Time (Index)", ylab = "Log Stock High")

# Close our PNG filewriter
dev.off()

# Redo regression with time
with_time <- lm(tesla_data$log.High ~ tesla_data$Close + tesla_data$Volume + 
                  tesla_data$Time)

# Output a summary of our regression data
summary(with_time)

# Get collinearity coefficients
vif(with_time)

# Get standard residuals from our regression
stdres_time <- rstandard(with_time)

# Open device for saving plot
png(filename = "fitted_vs_stdres_with_time.png", 
    width = 700, height = 700, units = "px",
    res = 120)

# Plot our fitted values against the standardized residuals
# "Versus Fits"
plot(fitted(with_time), stdres_time, 
     xlab = "Fitted values", ylab = "Standardized residuals",
     main = "Versus Fits")

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "stdres_vs_qq_percent_with_time.png", 
    width = 700, height = 700, units = "px",
    res = 120)

# Plot our Normal Probability
qqnorm(stdres_time, xlab = "Standardized Residual",
       main = "Normal Probability Plot")

# Close our PNG filewriter
dev.off()

# Cooks distance diagnostics
cbind(stdres_time, hatvalues(with_time), cooks.distance(with_time))

# Open device for saving plot
png(filename = "date_vs_standardized_residuals_with_time.png", 
    width = 1500, height = 600, units = "px",
    res = 120)

# Plot standardized residuals -- observe nc variance
plot(tesla_data$Time, stdres_time, 
     ylab = "Standardized residuals", xlab = "Date (Observation Order)",
     main = "Versus Order") + lines(tesla_data$Time, stdres_time)

# Close our PNG filewriter
dev.off()

# Calculate Durbin-Watson statistic
dwtest(tesla_data$log.High ~ tesla_data$Close + tesla_data$Volume + tesla_data$Time)

# z-statistic using s, Cook's distance
# cbind(stdres_time, hatvalues(with_time), cooks.distance(with_time))

# Open device for saving ACF plot
png(filename = "acf_with_time.png", 
    width = 1500, height = 600, units = "px",
    res = 120)

# Plot standardized residuals -- observe nc variance
acf(stdres_time, xlab = "Lag", ylab = "Autocorrelation", 
    ci = 0.95, ci.type = "ma", main = "Autocorrelation function for SRE", 
    ci.col = "red", verbose = TRUE)

# Close our PNG filewriter
dev.off()

## Lagging
# Include a lagged version of log.High as a predictor
tesla_data$lag.log.High <- lag(tesla_data$log.High, k = 1)

with_lag <- lm(tesla_data$log.High ~ tesla_data$Close + tesla_data$Volume + 
                              tesla_data$Time + tesla_data$lag.log.High)

# Output a summary of our regression data
summary(with_lag)

# Get collinearity coefficients
vif(with_lag)

# Get standard residuals from our regression
stdres_lag <- rstandard(with_lag)

# Open device for saving plot
png(filename = "scatter_matrix_with_lag.png",
    width = 1000, height = 1000, units = "px",
    res = 130)

# Plot all pairs 
pairs(~log.High + Close + Volume + lag.log.High,
      data = tesla_data, main = "Linear Correlation Plots")

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "fitted_vs_stdres_with_lag.png", 
    width = 700, height = 700, units = "px",
    res = 120)

# Plot our fitted values against the standardized residuals
# "Versus Fits"
plot(fitted(with_lag), stdres_lag, 
     xlab = "Fitted values", ylab = "Standardized residuals",
     main = "Versus Fits")

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "stdres_vs_qq_percent_with_lag.png", 
    width = 700, height = 700, units = "px",
    res = 120)

# Plot our Normal Probability
qqnorm(stdres_lag, xlab = "Standardized Residual",
       main = "Normal Probability Plot")

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "date_vs_standardized_residuals_with_lag.png", 
    width = 1500, height = 600, units = "px",
    res = 120)

# Plot standardized residuals -- observe nc variance
plot(tesla_data$Date[1:301], stdres_lag, 
     ylab = "Standardized residuals", xlab = "Date (Observation Order)",
     main = "Versus Order") + lines(tesla_data$Date[1:301], stdres_lag)

# Close our PNG filewriter
dev.off()

# Cooks distance diagnostics
cbind(stdres_lag, hatvalues(with_lag), cooks.distance(with_lag))

# Open device for saving ACF plot
png(filename = "acf_lag.png", 
    width = 1500, height = 600, units = "px",
    res = 120)

# Plot standardized residuals -- observe nc variance
acf(stdres_lag, xlab = "Lag", ylab = "Autocorrelation", 
    ci = 0.95, ci.type = "ma", main = "Autocorrelation function for SRE", 
    ci.col = "red", verbose = TRUE)

# Close our PNG filewriter
dev.off()

# Perform Runs test
runs.test(stdres_lag)
