## download and clean regional US flu data
## October 5 2016 - Nicholas Reich - created
## October 7 2016 - Evan Ray - calculate time using MMWRweek package, fix bug in
##   computation of season week
## October 7 2016 - Nicholas Reich - merged US and Regional data into one file.


library(plyr)
library(dplyr)
library(tidyr)
library(lubridate)
library(MMWRweek)
library(cdcfluview)
library(forcats)

 # regionflu1 <- get_flu_data("hhs",
 #   sub_region = 1:10,
 #   data_source = "ilinet",
 #   years = 1997:2018)

regionflu <- ilinet(region="hhs", years= 1997:2018)

usflu <- ilinet(region="national", years= 1997:2018)

## make AGE cols in usflu integer data type
cols <- matches('^AGE', vars=colnames(usflu))
usflu[,cols] <- sapply(usflu[,cols], as.integer)
cols <- matches('^AGE', vars=colnames(regionflu))
regionflu[,cols] <- sapply(regionflu[,cols], as.integer)

### something going on here
flu_data <- bind_rows(regionflu, usflu)

flu_data <- transmute(flu_data,
  region.type = `region_type`,
  region = fct_recode(region,
    National = "X"),
  year = year,
  week = week,
  time = as.POSIXct(MMWRweek2Date(year, week)),
  weighted_ili = as.numeric(`weighted_ili`))

## set zeroes to NAs
flu_data[which(flu_data$weighted_ili==0),"weighted_ili"] <- NA

## Add time_index column: the number of days since some origin date
## (1970-1-1 in this case).  The origin is arbitrary.
flu_data$time_index <- as.integer(date(flu_data$time) -  ymd("1970-01-01"))

## Season column: for example, weeks of 2010 up through and including week 30
## get season 2009/2010; weeks after week 30 get season 2010/2011
## Official CDC flu season for the purposes of prediction runs from week 40 of
## one year to week 20 of the next; the season start week we define here is the
## mid-point of the "off-season"
flu_data$season <- ifelse(
  flu_data$week <= 30,
  paste0(flu_data$year - 1, "/", flu_data$year),
  paste0(flu_data$year, "/", flu_data$year + 1)
)

## Season week column: week number within season
## weeks after week 30 get season_week = week - 30
## weeks before week 30 get season_week = week + (number of weeks in previous year) - 30
## This computation relies on the start_date function in package MMWRweek,
## which is not exported from that package's namespace!!!
flu_data$season_week <- ifelse(
  flu_data$week <= 30,
  flu_data$week + MMWRweek(MMWRweek:::start_date(flu_data$year) - 1)$MMWRweek - 30,
  flu_data$week - 30
)

flu_data <- as.data.frame(flu_data)

write.csv(flu_data, file = "data-raw/flu_data.csv")
save(flu_data, file = "data/flu_data.rdata")
