## hospital data SARIMA fits
## Oct 17 Started 
## Nicholas Reich, Casey Gibson

library(plyr);library(dplyr)
library(tidyr)
library(lubridate)
library(cdcFlu20182019)
library(forecast)
library(sarimaTD)

## do all regional fits in parallel
library(doMC)
registerDoMC(18)

data(hosp_data)
age_groups <- c("18-49 yr", "5-17 yr",  "Overall",  "65+ yr","50-64 yr", "0-4 yr" )

## get fits with seasonal differencing before call to auto.arima
## where to store SARIMA fits
path <- paste0("inst/estimation/hosp-sarima/fits-seasonal-differencing/")

for (age in age_groups){
message(paste(Sys.time(), "starting hospitalization with age ",age))
fit_hosp_sarima(data = hosp,
      age=age,
     first_test_season = "2017/2018",
    seasonal_difference = FALSE,
    transformation = "box-cox", 
    prediction_target_var = "unweighted_ili",
    path = path)
}


