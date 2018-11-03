## This code is based on inst/data-processing/create-clean-flu-data.R
## Updated for SARIMA-hospitalization submissions: 10/9/2018

library(plyr); library(dplyr)
library(cdcFlu20182019)
library(gridExtra)

submissions_save_path <- "inst/submissions/hosp-sarima"

data <- download_and_preprocess_hosp_data()


### Do prediction for sarima
## Parameters used in simulating trajectories
simulate_trajectories_sarima_params <- list(
  fits_filepath = "inst/estimation/hosp-sarima/fits-seasonal-differencing",
  prediction_target_var = "rate",
  seasonal_difference = FALSE,
  transformation = "box-cox",
  first_test_season = "2017/2018",
  age_groups = c("18-49 yr", "5-17 yr",  "Overall",  "65+ yr","50-64 yr", "0-4 yr" )
  
)


sarima_res <- get_submission_via_trajectory_simulation(
  data = data,
  analysis_time_season = "2017/2018",
  first_analysis_time_season_week = 10, # == week 40 of year
  last_analysis_time_season_week = 41, # analysis for 33-week season, consistent with flu competition -- at week 41, we do prediction for a horizon of one week ahead
  prediction_target_var = "unweighted_ili",
  incidence_bins = data.frame(
    lower = c(0, seq(from = 0.05, to = 12.95, by = 0.1)),
    upper = c(seq(from = 0.05, to = 12.95, by = 0.1), Inf)),
  incidence_bin_names = as.character(seq(from = 0, to = 13, by = 0.1)),
  n_trajectory_sims = 100,
  simulate_trajectories_function = sample_predictive_trajectories_arima_wrapper,
  simulate_trajectories_params = simulate_trajectories_sarima_params,
  all_regions = c("Entire Network"),
  regional="Hosp")







res_file <- file.path(submissions_save_path,
                      paste0(
                        "EW",
                        tail(data$week, 1),
                        "-KoT-Hosp-",
                        ymd(Sys.Date()),
                        ".csv"
                      )
)

plot_file <- file.path(submissions_save_path,
                       paste0(
                         "plots/EW",
                         tail(data$week, 1),
                         "-KoT-Hosp-",
                         ymd(Sys.Date()),
                         "-plots.pdf"
                       )
)

write.csv(sarima_res,
          file = res_file,
          row.names = FALSE)

#(FluSight::verify_entry_file(res_file, challenge = "hospital"))

### Plots for sanity

sarima_res <- read_entry(res_file)
