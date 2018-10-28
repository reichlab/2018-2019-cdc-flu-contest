## This code is based on inst/data-processing/create-clean-flu-data.R

library(plyr)
library(dplyr)
library(tidyr)
library(lubridate)
library(MMWRweek)
library(cdcfluview)
library(cdcFlu20182019)
library(forecast)
library(kcde)
library(copula)
library(FluSight)
library(gridExtra)

seasonal_difference <- TRUE
method <- paste0("sarima_seasonal_difference_", seasonal_difference)
submissions_save_path <- paste0("inst/submissions/region-", method)

data <- download_and_preprocess_flu_data()

analysis_time_season <- "2018/2019"

simulate_trajectories_sarima_params <- list(
  fits_filepath = paste0("inst/estimation/region-sarima/",
    ifelse(seasonal_difference,
      "fits-seasonal-differencing",
      "fits-no-seasonal-differencing")),
  prediction_target_var = "weighted_ili",
  seasonal_difference = seasonal_difference,
  transformation = "box-cox",
  first_test_season = "2018/2019"
)

weeks_in_first_season_year <-
  get_num_MMWR_weeks_in_first_season_year(analysis_time_season)

res <- get_submission_via_trajectory_simulation(
  data = data,
  analysis_time_season = analysis_time_season,
  first_analysis_time_season_week = 10, # == week 40 of year
  last_analysis_time_season_week = weeks_in_first_season_year - 11, # at week 41, we do prediction for a horizon of one week ahead
  prediction_target_var = "weighted_ili",
  incidence_bins = data.frame(
    lower = c(0, seq(from = 0.05, to = 12.95, by = 0.1)),
    upper = c(seq(from = 0.05, to = 12.95, by = 0.1), Inf)),
  incidence_bin_names = as.character(seq(from = 0, to = 13, by = 0.1)),
  n_trajectory_sims = 10000,
#  n_trajectory_sims = 100,
  simulate_trajectories_function = sample_predictive_trajectories_arima_wrapper,
  simulate_trajectories_params = simulate_trajectories_sarima_params)

res_file <- file.path(submissions_save_path,
  paste0(
    "EW", sprintf("%02d", tail(data$week, 1)),
    "-", tail(data$year, 1),
    "-ReichLab_", method,
    ".csv"))
write.csv(res,
  file = res_file,
  row.names = FALSE)


(FluSight::verify_entry_file(res_file))

### Plots for sanity

make_predictions_plots(
  preds_save_file = res_file,
  plots_save_file = paste0(
    submissions_save_path,
    "/plots/",
    tail(data$year, 1),
    "-",
    sprintf("%02d", tail(data$week, 1)),
    "-KOT-", method, "-plots.pdf"),
  data = data
)
