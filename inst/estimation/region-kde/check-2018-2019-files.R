## code to check 2018/2019 submissions

library(FluSight)
library(ggplot2)
library(gridExtra)

tmp <- read_entry("inst/submissions/region-kde/EW01-2019-ReichLab_kde.csv")

pdf("check_all_files.pdf", width = 12)
for(reg in unique(tmp$location)){
  p_onset <- plot_onset(tmp, region = reg) + ylim(0,1) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=.5, size=5))
  p_peakpct <- plot_peakper(tmp, region = reg) + ylim(0,1)
  p_peakwk <- plot_peakweek(tmp, region = reg) + 
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=.5, size=5))
  p_1wk <- plot_weekahead(tmp, region = reg, wk = 1, ilimax=13, years = 2017, plot_current=FALSE) + 
    ggtitle(paste(reg, ": 1 wk ahead")) + ylim(0,1)
  p_2wk <- plot_weekahead(tmp, region = reg, wk = 2, ilimax=13, years = 2017, plot_current=FALSE) + ylim(0,1)
  p_3wk <- plot_weekahead(tmp, region = reg, wk = 3, ilimax=13, years = 2017, plot_current=FALSE) + ylim(0,1)
  p_4wk <- plot_weekahead(tmp, region = reg, wk = 4, ilimax=13, years = 2017, plot_current=FALSE) + ylim(0,1)
  grid.arrange(p_1wk, p_2wk, p_3wk, p_4wk, p_onset, p_peakpct, p_peakwk, ncol=4)
}
dev.off()


library(tidyr)
library(ggplot2)
library(dplyr)

region_strings <- c("National", paste0("Region", 1:10))
seasons_to_check <- "2018-2019" #paste0(2010:2015, "-", 2011:2016)

pdf("inst/estimation/region-kde/check-kde-predictions.pdf", width=10)
for(reg in region_strings) {
    # reg = region_strings[1]
    for(season in seasons_to_check) {
        fname <- paste0("inst/estimation/region-kde/fits/kde-", reg, "-fit-prospective-", season, ".rds")
        tmp <- readRDS(fname)
        tmp1 <- as_data_frame(tmp) %>% 
            gather(
                key=metric, value=log_score, 
                -c(model, 
                    starts_with("prediction_week_ph"), 
                    starts_with("analysis_time"),
                    ends_with("log_prob"),
                    contains("competition"))
            ) %>%
            ## exclude pandemic season
            filter(analysis_time_season != "2009/2010")
        if(exists("tmp2")) {
            tmp2 <- rbind(tmp2, tmp1)
        } else {
            tmp2 <- tmp1
        }
    }
    p <- ggplot(tmp2, aes(x=analysis_time_season_week, y=log_score)) +
        geom_line(aes(color=factor(analysis_time_season))) +
        facet_grid(.~factor(metric)) +
        geom_smooth(se=FALSE, color="black") +
        ylim(-10, 0) + ggtitle(reg)
    print(p)
    rm(tmp2)
}
dev.off()