#' Plots Week Ahead Forecasts
#'
#' This function allows you to plot Weak Ahead Predictions
#' @param dat Expects a data csv in the form of a CDC fluview submission see \code{FluSight} package for a minimal submission
#' @param region Specifies the region to be plotted
#' @param wk Numeric. How many weeks ahead to plot. Defaults to 1.
#' @param ilimax Numeric. Max level of ILI percentage to be plotted
#' @keywords Week Ahead Prediction Plots
#' @export
#' @examples
#' plotWeekAhead()

my_plot_weekahead <- function(dat, region, wk=1, ilimax, years=NA){
    require(ggplot2)
    require(cdcfluview)
    
    d <- suppressWarnings(subset(dat, location==region & as.numeric(as.character(bin_start_incl)) <= ilimax))
    d <- d[grep("wk ahead", d$target),]
    
    NatFluDat <- get_flu_data("national", NA, "ilinet", years=years)
    RegFluDat <- get_flu_data("hhs", 1:10, "ilinet", years=years)
    StateFluDat <- get_flu_data("state", "all", "ilinet", years=years)
    ## kludgy work-around
    StateFluDat$`% WEIGHTED ILI` <- StateFluDat$`%UNWEIGHTED ILI`
    NatFluDat$REGION[NatFluDat$REGION=="X"] <- "National"
    CFluDat <- rbind(
        tail(RegFluDat, n=10), 
        tail(NatFluDat, n=1),
        tail(StateFluDat, n=53))[,c("REGION","% WEIGHTED ILI")]
    if(region=="US National"){
        CurrentILIPer <- as.numeric(CFluDat[CFluDat$REGION=="National", "% WEIGHTED ILI"])
    }else if(region %in% paste("Region", 1:10)){
        CurrentILIPer <- as.numeric(CFluDat[CFluDat$REGION==paste("Region", strsplit(region, " ")[[1]][3]), "% WEIGHTED ILI"])
    } else {
        CurrentILIPer <- as.numeric(CFluDat[CFluDat$REGION==region, "% WEIGHTED ILI"])
    }
    
    if(wk==1){
        return(ggplot(data=subset(d, target=="1 wk ahead"), aes(x=as.numeric(as.character(bin_start_incl)), y=value)) + 
                geom_point() + labs(title = "1 Week Ahead", x="ILI%", y="Prob") + geom_vline(aes(xintercept = CurrentILIPer)))
    }
    
    
    if(wk==2){
        return(ggplot(data=subset(d, target=="2 wk ahead"), aes(x=as.numeric(as.character(bin_start_incl)), y=value)) + 
                geom_point() + labs(title = "2 Week Ahead", x="ILI%", y="Prob") + geom_vline(aes(xintercept = CurrentILIPer)))
    }
    
    if(wk==3){
        return(ggplot(data=subset(d, target=="3 wk ahead"), aes(x=as.numeric(as.character(bin_start_incl)), y=value)) + 
                geom_point() + labs(title = "3 Week Ahead", x="ILI%", y="Prob") + geom_vline(aes(xintercept = CurrentILIPer)))
    }
    
    if(wk==4){
        return(ggplot(data=subset(d, target=="4 wk ahead"), aes(x=as.numeric(as.character(bin_start_incl)), y=value)) + 
                geom_point() + labs(title = "4 Week Ahead", x="ILI%", y="Prob") + geom_vline(aes(xintercept = CurrentILIPer)))
    }
    
}
