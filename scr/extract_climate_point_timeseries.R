#=================================================================================================
#EXTRACT TIME SERIES for a certain location from a raster objects
#=================================================================================================
#extract data from raster stack according to lat lon coordinates
#this calls in .nc files from a certain directory
#according to a list of desired parameters as defined in their filenames
#and according to the specified lat lons
#extracts out the relevant files

#packages required:
library(raster)   
library(data.table)


point_timeseries<-function(stack, parameters, lat, lon){
  for (j in(1:length(parameters))){
	if(typeof(stack)==typeof("filepath")){
            filenames<-list.files(path = indir, pattern = parameters[j])
	    print(indir)
	    print(parameters[j])
	    print("the list of filenames:")
	    print(filenames)
	    pathname<-paste(indir, filenames, sep="")
	    print("This is the pathname:")
	    print(pathname)
	    b<- brick(pathname, varname="variable") #as a rasterbrick
        }else{
	    b<-brick(unlist(stack[[j]]))  
  }
    #print(b)
    x<-raster::extract(b, SpatialPoints(cbind(lat, lon)))[1:nlayers(b)]
    #points.sp <- (as.data.frame(cbind(lon, lat)))
    #coordinates(points.sp) <- ~ lon + lat
    #climate.points <- raster::extract(b, points.sp) #extract from the raster layers
    print(head(x))
    climate_list[[j]]<-x
  }
  df<-matrix(ncol=length(climate_list), nrow=length(climate_list[[1]]), data=NA)
  #df[,]<-as.data.frame(unlist(climate_list))
  #print(head(df))
  #print(tail(df))	
  #colnames(df)<-unlist(parameters)
  for (i in(1:length(parameters))){
    df[,i]<-as.numeric(unlist(climate_list[[i]]))
    print(parameters[i])
    #colnames(df[,i])<-paste(parameters[i])
  }
  df1<-as.data.frame(df)
  colnames(df1)<-parameters
  print(head(df1))
  return(df1)
}

  
