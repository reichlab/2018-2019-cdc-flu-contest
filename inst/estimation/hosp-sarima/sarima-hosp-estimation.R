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


## get fits with seasonal differencing before call to auto.arima
## where to store SARIMA fits
path <- paste0("inst/estimation/hosp-sarima/fits-seasonal-differencing/")

#foreach(i = seq_len(nrow(region_seasons))) %dopar% {
message(paste(Sys.time(), "starting hospitalization"))
fit_hosp_sarima(data = hosp,
     first_test_season = "2017/2018",
    seasonal_difference = FALSE,
    transformation = "box-cox", 
    prediction_target_var = "unweighted_ili",
    path = path)

