## This code is based on inst/data-processing/create-clean-flu-data.R
## Updated for SARIMA-state submissions: 10/9/2018

library(plyr); library(dplyr)
library(cdcFlu20182019)
library(gridExtra)
library(FluSight)

submissions_save_path <- "inst/submissions/state-sarima"

data <- download_and_preprocess_state_flu_data()

state_names <- unique(data$region)
state_names <- state_names[-which(state_names %in% c("Florida"))]
#state_names <- state_names[1:2] ## for testing

### Do prediction for sarima
## Parameters used in simulating trajectories
simulate_trajectories_sarima_params <- list(
  fits_filepath = "inst/estimation/state-sarima/fits-seasonal-differencing",
  prediction_target_var = "unweighted_ili",
  seasonal_difference = TRUE,
  transformation = "box-cox",
  first_test_season = "2018/2019"
)

sarima_res <- get_submission_via_trajectory_simulation(
    data = data,
    analysis_time_season = "2018/2019",
    first_analysis_time_season_week = 10, # == week 40 of year
    last_analysis_time_season_week = 41, # analysis for 33-week season, consistent with flu competition -- at week 41, we do prediction for a horizon of one week ahead
    prediction_target_var = "unweighted_ili",
    incidence_bins = data.frame(
        lower = c(0, seq(from = 0.05, to = 12.95, by = 0.1)),
        upper = c(seq(from = 0.05, to = 12.95, by = 0.1), Inf)),
    incidence_bin_names = as.character(seq(from = 0, to = 13, by = 0.1)),
    n_trajectory_sims = 10000,
    simulate_trajectories_function = sample_predictive_trajectories_arima_wrapper,
    simulate_trajectories_params = simulate_trajectories_sarima_params,
    all_regions = state_names,
    regional="State")


res_file <- file.path(submissions_save_path,
  paste0(
      "EW",
      tail(data$week, 1),
      "-KoT-StateILI-",
      ymd(Sys.Date()),
      ".csv"
  )
)

plot_file <- file.path(submissions_save_path,
    paste0(
        "plots/EW",
        tail(data$week, 1),
        "-KoT-StateILI-",
        ymd(Sys.Date()),
        "-plots.pdf"
    )
)

write.csv(sarima_res,
  file = res_file,
  row.names = FALSE)

if(!FluSight::verify_entry_file(res_file, challenge = "state_ili"))
  stop("entry file not valid.")

### Plots for sanity

sarima_res <- read_entry(res_file)

pdf(plot_file, width = 12)
for(reg in unique(sarima_res$location)){
    p_peakpct <- plot_peakper(sarima_res, region = reg) + ylim(0,1)
    p_peakwk <- plot_peakweek(sarima_res, region = reg) + ylim(0,1) +
        theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=.5, size=5))
    p_1wk <- my_plot_weekahead(sarima_res, region = reg, wk = 1, ilimax=13, years = 2018:2019) + ggtitle(paste(reg, ": 1 wk ahead")) + ylim(0,1)
    p_2wk <- my_plot_weekahead(sarima_res, region = reg, wk = 2, ilimax=13, years = 2018:2019) + ylim(0,1)
    p_3wk <- my_plot_weekahead(sarima_res, region = reg, wk = 3, ilimax=13, years = 2018:2019) + ylim(0,1)
    p_4wk <- my_plot_weekahead(sarima_res, region = reg, wk = 4, ilimax=13, years = 2018:2019) + ylim(0,1)
    grid.arrange(p_1wk, p_2wk, p_3wk, p_4wk, p_peakpct, p_peakwk, ncol=4)
}
dev.off()
