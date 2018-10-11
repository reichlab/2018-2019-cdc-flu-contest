## make a set of prospective prediction files for KDE/GAM model
## these files used for the collaborative ensemble
## Nicholas Reich
## July 2017

library(cdcFlu20182019)
library(doMC)

FIRST_YEAR_OF_LAST_SEASON <- 2017

n_sims <- 10000
prospective_seasons <- paste0(2010:FIRST_YEAR_OF_LAST_SEASON, "/", 2011:(FIRST_YEAR_OF_LAST_SEASON+1))
season_weeks <- 10:43

## for 2018-2019 season, 
## first predictions due on 10/29/2018 (EW44 == SW14)  MMWRweek("2018-10-29")
## using data posted on 10/26/2016 that includes up to EW42 == SW12
## last predictions due on 5/13/2017 (EW20 == SW 42) MMWRweek("2019-05-13")
## last predictions use data through EW18 == SW40
## first_analysis_time_season_week could be set to 15, but padding at front end
registerDoMC(4)

for(season in prospective_seasons){
    foreach(season_week = season_weeks) %dopar% {
    make_one_kde_prediction_file(save_path = "inst/prospective-predictions/kde/",
                                 fits_path = "inst/estimation/kde/fits/",
                                 season = season,
                                 season_week = season_week,
                                 n_sim = n_sims)
  }
}

