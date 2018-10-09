## utility functions for SARIMA fits

#' Estimate SARIMA model using data up to but not including first_test_season
#'
#' @param data regional dataset with structure like regionflu-cleaned
#' @param reg_num region number for estimation
#' @param first_test_season string indicating first test season
#' @param d order of first differencing
#' @param D order of seasonal differencing
#' @param seasonal_difference boolean; take a seasonal difference before passing
#'   to auto.arima?
#' @param transformation character specifying transformation type:
#'   "box-cox", "log", or "none" (default is "none")
#' @param prediction_target_var character specifying column name of modeled 
#'   variable, defaults to "weighted_ili" 
#' @param path path in which to save files
#'
#' @return NULL just saves files
#'
#' @export
fit_region_sarima <- function(
  data,
  region,
  first_test_season,
  d = NA,
  D = NA,
  seasonal_difference = TRUE,
  transformation = c("none", "box-cox", "log"),
  prediction_target_var = "weighted_ili",
  path) {
    
  transformation <- match.arg(transformation)
    
  require(sarimaTD)
  
  ## subset data to be only the region of interest
  data <- data[data$region == region,]

  ## Subset data to do estimation using only data up to (and not including)
  ## first_test_season.  remainder are held out
  first_ind_test_season <- min(which(data$season == first_test_season))
  data <- data[seq_len(first_ind_test_season - 1), , drop = FALSE]

  sarima_fit <- fit_sarima(
    y = data[, prediction_target_var],
    ts_frequency = 52,
    transformation = transformation,
    seasonal_difference = seasonal_difference,
    d = d,
    D = D)

  filename <- paste0(
    path,
    "sarima-",
    gsub(" ", "_", region),
    "-seasonal_difference_", seasonal_difference,
    "-transformation_", transformation,
    "-first_test_season_", gsub("/", "_", first_test_season),
    ".rds")
  saveRDS(sarima_fit, file = filename)
}
