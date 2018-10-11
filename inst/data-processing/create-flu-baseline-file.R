## create long flu baseline dataset
## Nicholas Reich
## October 2016

library(tidyr)
library(dplyr)
library(readr)

## temporary link from pull request file. change back when master file is updated.
## dat <- read.csv("https://raw.githubusercontent.com/cdcepi/FluSight-forecasts/master/wILI_Baseline.csv")
dat <- read_csv("https://raw.githubusercontent.com/cdcepi/FluSight-forecasts/1d0658560fa2378eff7b89f903582af4b3b07e5e/wILI_Baseline.csv")
dat <- as_data_frame(dat) %>%
    gather(key=year, value=baseline, -X1) %>%
    transmute(region = as.character(X1),
              season = substr(year, start=1, stop=9), ## removes X at beginning of season name
              baseline=baseline)

## fill in baselines for seasons before 2007/2008 with means
mean_region_baseline <- dat %>%
  group_by(region) %>%
  summarize(baseline = round(mean(baseline), 1))
mean_region_baseline <- mean_region_baseline[c(1:2, 4:11, 3), ]

regions <- c("National", paste0("Region", 1:10))
for(first_season_year in 2006:1997) {
  dat <- bind_rows(
    data.frame(
      region = regions,
      season = paste0(first_season_year, "/", first_season_year + 1),
      baseline = mean_region_baseline$baseline
    ),
    dat
  )
}

flu_onset_baselines <- as.data.frame(dat)

# ggplot(flu_onset_baselines) +
#   geom_line(aes(x=as.numeric(substr(season, 1,4)), y=baseline, color=region))

write.csv(dat, "data-raw/flu_onset_baselines.csv", quote = FALSE, row.names = FALSE)
save(flu_onset_baselines, file = "data/flu_onset_baselines.rdata")
