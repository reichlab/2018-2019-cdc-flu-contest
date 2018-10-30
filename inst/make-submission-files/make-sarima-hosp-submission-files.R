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
  first_test_season = "2017/2018"
)
first_analysis_time_season_week <- 10 # == week 40 of year
last_analysis_time_season_week <- 41 
analysis_time_season = "2018/2019"
analysis_time_season_week <- data$season_week[nrow(data)]


max_prediction_horizon <- max(4L,
                              last_analysis_time_season_week + 1 - analysis_time_season_week)

n_sims <-100

res <- sample_predictive_trajectories_arima_wrapper(
  n_sims,
  max_prediction_horizon,
  data,
  "hosp",
  analysis_time_season,
  analysis_time_season_week,
  simulate_trajectories_sarima_params
)

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

write.csv(res,
          file = res_file,
          row.names = FALSE)

(FluSight::verify_entry_file(res_file, challenge = "hospital"))

### Plots for sanity

sarima_res <- read_entry(res_file)

pdf(plot_file, width = 12)
for(reg in unique(sarima_res$location)){
  p_peakpct <- plot_peakper(sarima_res, region = reg) + ylim(0,1)
  p_peakwk <- plot_peakweek(sarima_res, region = reg) + ylim(0,1) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=.5, size=5))
  p_1wk <- my_plot_weekahead(sarima_res, region = reg, wk = 1, ilimax=13, years = 2017:2018) + ggtitle(paste(reg, ": 1 wk ahead")) + ylim(0,1)
  p_2wk <- my_plot_weekahead(sarima_res, region = reg, wk = 2, ilimax=13, years = 2017:2018) + ylim(0,1)
  p_3wk <- my_plot_weekahead(sarima_res, region = reg, wk = 3, ilimax=13, years = 2017:2018) + ylim(0,1)
  p_4wk <- my_plot_weekahead(sarima_res, region = reg, wk = 4, ilimax=13, years = 2017:2018) + ylim(0,1)
  grid.arrange(p_1wk, p_2wk, p_3wk, p_4wk, p_peakpct, p_peakwk, ncol=4)
}
dev.off()
