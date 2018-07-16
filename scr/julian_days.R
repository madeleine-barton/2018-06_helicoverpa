#a function to specify the day of year, while taking into account leap years
#receives a list of the years, and returns a  vectory of day of year
#assuming simulation starts on teh first of january
#and that we are working on daily timesteps
is.leapyear=function(year){
  return(((year %% 4 == 0) & (year %% 100 != 0)) | (year %% 400 == 0))
}

library(geosphere)

julian_days<-function(years, Hem, lat){
  for (i in (1:length(years))){
    if(is.leapyear(as.numeric(years[i]))){
      days<-seq(1, 366, 1)
      photophase<-geosphere::daylength(lat, days)
      print(lat)
      if(Hem=="S"){
        season<-ifelse((days<174)& (days>357),"Spring", "Autumn")
      }else{
        season<-ifelse((days<174)& (days>357),"Autumn", "Spring") 
      }
    }else{
      days<-seq(1, 365, 1)
      photophase<-geosphere::daylength(lat, days)
      if(Hem=="S"){
        season<-ifelse((days>173)& (days<356),"Spring", "Autumn")
      }else{
        season<-ifelse((days>173)& (days<356),"Autumn", "Spring") 
    }
  }
    if(i==1){
      doy<-as.data.frame(cbind(days, photophase, season))
    }else{
      d<-as.data.frame(cbind(days, photophase, season))
      doy<-rbind(doy,d)
    }
  }
  return(doy)
}
























