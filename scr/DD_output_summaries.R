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
     df1<-df %>%
     group_by(SITE)%>%
     summarise(lat = mean(lat), lon = mean(lon), heat_stress = max(as.numeric(heat_stress)))
     return(df1)
}

cold_deaths<-function(df){
     df1<-df %>%
     group_by(SITE)%>%
     summarise(lat = mean(lat), lon = mean(lon), cold_stress = max(as.numeric(cold_stress)))
     return(df1)
}

