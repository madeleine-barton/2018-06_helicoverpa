
#!/bin/R

#Signature: convert_to_hourly
#Purpose: to convert the daily temperature in hourly conditions using
#equations from Campbell and Norman 1998

#indir = the directory where two stacks, min_temp/max_temp are
#found, both stacks should have the same extent, and coresponding
#layers of timesteps(i.e. same layers are the sames times on each)
rm(list=ls())

convert_to_hourly<-function(indir){
  tmin<-list.files(path = indir, pattern = "multiyear_min_temp")[1] #at the moment, just doing the first file that is listed
  pathname<-paste(indir, tmin, sep="")
  tmin<- brick(pathname, varname="variable")
  
  tmax<-list.files(path = indir, pattern = "multiyear_max_temp")[1]
  pathname<-paste(indir, tmax, sep="")
  tmax<- brick(pathname, varname="variable")
  
  #if((tmin$names[1]) != (tmax$names[1])){
  #  print("dates of files do not match")
  #  break
  #}
  #generate a new stack in which to put hourly temperature
  #start the C&N loop here, calling straight from the stacks
  #START THE LOOP
  ###Turning max/mins into hourly temperatures with sin curve (Campbell and Norman, pg 23)
  sin.coeff<-c(0.126771118, 0.087313005, 0.051442082,0.028362076, 0.030063024,0.067716061, 0.147891549, 0.269666798, 0.423474766, 0.5920971,0.753642471, 0.885823934, 0.970498103, 0.997348188, 0.965804913, 0.884748339, 0.770101103, 0.640959333, 0.515270167, 0.406159218, 0.319814007, 0.255394846, 0.206890319, 0.166309673)
  #sin.coeff<-rep(sin.coeff,nlayers(tmin)) #multiplying the coefficient by the number of days at each site
  #hour<-rep(1:24, nlayers(tmin)) #generate an hour vector that matches the sin_coefficient
  hourly<-stack()   #setting up an empty stack to load the files
  hourly[[1:24]]<-stack(hourly, tmin[[1]]) #check this

rm(i)
  for(i in (2:(nlayers(tmin)-1))){ # looping through the number of days layers in tmin
    inner<-stack()
    for(j in (1:24)){
      if(j<5){                                                 #hours before 5am
        x<-(sin.coeff[j]*tmax[[i-1]])+((1-sin.coeff[j])*tmin[[i]])
        inner<-stack(inner,x)  }
      if((j>=5 & j<=14)){                             #hours between 5 and 14
        x<-(sin.coeff[j]*tmax[[i]])+((1-sin.coeff[j])*tmin[[i]])
        inner<-stack(inner,x)  }
      if(j>14){                                                   #hours after 14
        x<-(sin.coeff[j]*tmax[[i]])+((1-sin.coeff[j])*tmin[[i+1]])
        inner<-stack(inner,x)  }}
    hourly<-stack(hourly, inner)
    print(i)
  }

  hourly[(nlayers(hourly)+1):(nlayers(hourly)+24)]<-stack(hourly, tmin[[nlayers(tmin)]]) #check this

  writeRaster(hourly, paste(indir, "hourly.temperatures.nc", sep=""), overwrite=TRUE)
  #write out the final stack back out to the indir, but named hourly
}
plot(hourly)

hourly[[i]]<-(sin.coeff[i]*(tmax[[i]])+(sin.coeff[i]*tmin[[i-1]]))
