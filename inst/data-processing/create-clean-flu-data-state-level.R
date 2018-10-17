## download and clean regional US flu data
## October 5 2016 - Nicholas Reich - created
## October 7 2016 - Evan Ray - calculate time using MMWRweek package, fix bug in
##   computation of season week
## October 7 2016 - Nicholas Reich - merged US and Regional data into one file.
## November 2 2017 - Nicholas Reich - forked for state-level data

state_flu <- download_and_preprocess_state_flu_data(latest_year = 2018)

write.csv(state_flu, file = "data-raw/state_flu_data.csv")
save(state_flu, file = "data/state_flu_data.rdata")
