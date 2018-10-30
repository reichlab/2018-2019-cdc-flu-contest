## download and clean US hosp data
## Oct 17 

hosp <- download_and_preprocess_hosp_data(latest_year = 2018)

write.csv(hosp, file = "data-raw/hosp_data.csv")
save(hosp, file = "data/hosp_data.rdata")
