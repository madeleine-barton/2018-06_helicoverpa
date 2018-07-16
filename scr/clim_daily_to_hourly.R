
#Taking two vectors of minimum and maximum temperatures and converting them into
#hourly temperatures

convert_to_hourly<-function(Tmin, Tmax){
  ###Turning max/min temperatures into hourly temperatures assuming a sin curve (Campbell and Norman, pg 23)
  sin.coeff<-c(0.126771118, 0.087313005, 0.051442082,0.028362076, 0.030063024,0.067716061, 0.147891549, 0.269666798, 0.423474766, 0.5920971,0.753642471, 0.885823934, 0.970498103, 0.997348188, 0.965804913, 0.884748339, 0.770101103, 0.640959333, 0.515270167, 0.406159218, 0.319814007, 0.255394846, 0.206890319, 0.166309673)
  #sin.coeff<-rep(sin.coeff,nlayers(tmin)) #multiplying the coefficient by the number of days at each site
  #generate an hour list tinto which data are saved
  hourly<-list()   #setting up an empty stack to load the files
  hourly[1:24]<-(Tmin[1]+Tmax[1])/2#check this
  #cycle through the hourly loop and append each hour's temperature first to the inner list, and then once
  #the day is done, append the day to the hourly list
  for(i in (2:(length(Tmin)-1))){ # looping through the number of days layers in tmin
    inner<-list()
    for(j in (1:24)){
      if(j<5){                                                 #hours before 5am
        x<-(sin.coeff[j]*Tmax[i-1])+((1-sin.coeff[j])*Tmin[i])
        inner<-c(inner,x)  }
      if((j>=5 & j<=14)){                                       #hours between 5 and 14
        x<-(sin.coeff[j]*Tmax[i])+((1-sin.coeff[j])*Tmin[i])
        inner<-c(inner,x)  }
      if(j>14){                                                   #hours after 14
        x<-(sin.coeff[j]*Tmax[i])+((1-sin.coeff[j])*Tmin[i+1])
        inner<-c(inner,x)  }}
    hourly<-c(hourly, inner)
#    print(i)
  }
#For the final day, when we don't have information for the next day, assumed the entire day is
#the mean temperature (for bening conditions)'
  hourly[(length(hourly)+1):(length(hourly)+24)]<-(Tmin[length(Tmin)]+Tmax[length(Tmax)])/2 #check this
#unlist the hourly temperatures and return, ready to use in teh DegDay simulation (or other)
  Ta<-unlist(hourly)
  return(Ta)
}
