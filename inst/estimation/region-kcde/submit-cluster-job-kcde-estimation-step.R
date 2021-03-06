options(warn = 2)

all_data_sets <- c("National", paste0("Region-", 1:10))
#all_data_sets <- "National"
#all_prediction_horizons <- as.character(seq_len(35))
#all_prediction_horizons <- as.character(seq_len(1))
all_prediction_horizons <- as.character(seq(from = 2, to = 35, by = 1))
#all_prediction_horizons <- 1L
all_seasonality_values <- c("TRUE")
all_first_test_seasons <- paste0(2017:2018, "/", 2018:2019)
#all_first_test_seasons <- "2017/2018"
#all_first_test_seasons <- paste0(2010:2016, "/", 2011:2017)
#all_seasons_left_out <- c(paste0(1997:2010, "/", 1998:2011), "none")
all_max_lags <- 1L

cores_req <- "4"
mem_req <- "5000"
time_req <- "8:00"
queue_req <- "long"
#time_req <- "4:00"
#queue_req <- "short"

for(data_set in all_data_sets) {
  for(prediction_horizon in all_prediction_horizons) {
    for(max_lag in all_max_lags) {
      for(seasonality in all_seasonality_values) {
        for(first_test_season in all_first_test_seasons) {
#          for(season_left_out in all_seasons_left_out) {
            save_path <- "/home/er71a/2018-2019-cdc-flu-contest/inst/estimation/region-kcde/fits"
            output_path <- "/home/er71a/2018-2019-cdc-flu-contest/inst/estimation/region-kcde/cluster-output"
            lsfoutfilename <- "kcde-estimation-step.out"

            case_descriptor <- paste0(
              data_set,
              "-prediction_horizon_", prediction_horizon,
              "-max_lag_", max_lag,
              "-seasonality_", seasonality,
#              "-season_left_out_", gsub("/", "-", season_left_out),
              "-first_test_season_", gsub("/", "-", first_test_season)
            )
            filename <- paste0(output_path, "/submit-kcde-estimation-step-", case_descriptor, ".sh")

            results_filename <- file.path(save_path,
              paste0("kcde_fit-",
                case_descriptor,
                ".rds")
            )
            
            if(!file.exists(results_filename)) {
              requestCmds <- "#!/bin/bash\n"
              requestCmds <- paste0(requestCmds, "#BSUB -n ", cores_req, " # how many cores we want for our job\n",
                "#BSUB -R span[hosts=1] # ask for all the cores on a single machine\n",
                "#BSUB -R rusage[mem=", mem_req, "] # ask for memory\n",
                "#BSUB -o ", lsfoutfilename, " # log LSF output to a file\n",
                "#BSUB -W ", time_req, " # run time\n",
                "#BSUB -q ", queue_req, " # which queue we want to run in\n")

              cat(requestCmds, file = filename)
              cat("module load R/3.4.0\n", file = filename, append = TRUE)
              cat(paste0("R CMD BATCH --vanilla \'--args ",
                         data_set, " ",
                         prediction_horizon, " ",
                         max_lag, " ",
                         seasonality, " ",
#                        season_left_out, " ",
                         first_test_season, " ",
                         save_path,
                         "\'  /home/er71a/2018-2019-cdc-flu-contest/inst/estimation/region-kcde/kcde-estimation-step.R ",
                         output_path, "/output-kde-estimation-step-", case_descriptor, ".Rout"),
                  file = filename, append = TRUE)

               bsubCmd <- paste0("bsub < ", filename)

               system(bsubCmd)
             }
#          } # season_left_out
        } # first_test_season
      } # seasonality
    } # max_lag
  } # prediction_horizon
} # data_set
