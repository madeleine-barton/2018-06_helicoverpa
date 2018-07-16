#=================================================================================================
#Generate summaries of the RAW_DATA model outputs from a degree_day model that's been run
#=================================================================================================
#using the RAW_DATA output table from a degree_day model, generate a summary dataframe with relevant
#information (at the moment, just the number of generations)

library(tidyverse)
voltinism<-function(df){
    df1<-df %>%
    group_by(SITE)%>%
    summarise(lat = mean(lat), lon = mean(lon), voltinism = max(as.numeric(new_gen)))
    return(df1)
}

heat_deaths<-function(df){
     x<-aggregate(as.numeric(as.character(df$heat_stress)), by=list(df$SITE),sum)$x
     #df<-cbind(df, x)
     #df1<-df %>%
     #group_by(SITE)%>%
     #summarise(lat = mean(lat), lon = mean(lon), heat_stress = sum(as.numeric(heat_stress)))
     return(x)
}

cold_deaths<-function(df){
     x<-aggregate(as.numeric(as.character(df$cold_stress)), by=list(df$SITE),sum)$x
     #df1<-df %>%
     #group_by(SITE)%>%
     #summarise(lat = mean(lat), lon = mean(lon), cold_stress = sum(as.numeric(cold_stress)))
     return(x)
}

diapause_hours<-function(df){
     x<-aggregate(as.numeric(as.character(df$diapause)), by=list(df$SITE),sum)$x
     return(x)
}
