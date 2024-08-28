# Load required libraries
install.packages("readxl")
install.packages("DescTools")
install.packages("openxlsx")
install.packages("tidyverse")
install.packages("car")
install.packages("lmtest")
install.packages("forecast")
install.packages("tseries")

library(readxl)
library(DescTools)
library(readr)
library(openxlsx)
library(tidyverse)
library(car)           # To check multicollinearity
library(lmtest)
library(forecast)
library(tseries)
library(lubridate)

# Reading the data from the csv file
data <- read.csv("#Copy file path")

# Display the internal structure of the data table
str(data)

# Attach the dataset to the R environment for easier access to variables
attach(data)

# Checking correlation between variables
cor(Gold_Price, Crude_Oil)
cor(Gold_Price, Interest_Rate)
cor(Gold_Price, USD_INR)
cor(Gold_Price, Sensex)
cor(Gold_Price, CPI)
cor(Gold_Price, USD_Index)
cor(USD_INR, USD_Index)

# Get the summary statistics of each individual variable
summary(data)

# Get the standard deviation of all variables
sapply(data[,c(2,3,4,5,6,7,8)], sd)

# Get the interquartile range (IQR) of all variables
sapply(data[,c(2,3,4,5,6,7,8)], IQR)

# Get the variance of all variables
sapply(data[,c(2,3,4,5,6,7,8)], var)

# Linear regression model with all predictors
fullfit <- lm(Gold_Price ~ Crude_Oil + Interest_Rate + USD_INR + Sensex + CPI + USD_Index)
summary(fullfit)

# Plot residuals vs fitted values for the full model
plot(fitted(fullfit), resid(fullfit))
abline(0, 0)

# Reduced linear regression model without USD_Index
reducedfit <- lm(Gold_Price ~ Crude_Oil + Interest_Rate + USD_INR + Sensex + CPI)
summary(reducedfit)

# Plot residuals vs fitted values for the reduced model
plot(fitted(reducedfit), resid(reducedfit))
abline(0, 0)

# Log transformation to address heteroscedasticity
fit1 <- lm(log(Gold_Price) ~ Crude_Oil + Interest_Rate + USD_INR + Sensex + CPI)
summary(fit1)

# Plot residuals vs fitted values for the log-transformed model
plot(fitted(fit1), resid(fit1))
abline(0, 0)

# Stepwise regression to refine the model
fit2 <- step(fit1)
summary(fit2)

# Plot residuals vs fitted values for the refined model
plot(fitted(fit2), resid(fit2))
abline(0, 0)

# Check for multicollinearity using Variance Inflation Factors (VIF)
vif(fit2)

# Create a correlation matrix for the independent variables
df <- data.frame(Crude_Oil, Interest_Rate, USD_INR, Sensex, CPI, USD_Index)
cor_matrix <- cor(df)
cor_matrix

# Time Series Analysis

# Convert Gold_Price data into a time series object
ts_data <- ts(data$Gold_Price, start = c(2000, 10), end = c(2020, 8), frequency = 12)

# Plot the time series data
plot(ts_data)
abline(lm(Gold_Price ~ time(ts_data)))

# Check stationarity using the Augmented Dickey-Fuller test
adf.test(diff(log(ts_data)), alternative = "stationary", k = 0)

# Plot ACF and PACF for the log-transformed time series
acf(log(ts_data))
pacf(log(ts_data))
acf(diff(log(ts_data)))
pacf(diff(log(ts_data)))

# Fit an ARIMA model to the time series
model <- auto.arima(ts_data, seasonal = FALSE, stepwise = TRUE)
summary(model)

# Forecast future values using the ARIMA model
fit <- arima(log(ts_data), c(7, 1, 1), seasonal = list(order = c(7, 1, 1), period = 12))
pred <- predict(fit, n.ahead = 3*12) # Predict the next 3 years of data

# Plot the original and predicted values
ts.plot(ts_data, 2.718^pred$pred, log = "y", lty = c(1, 3))
