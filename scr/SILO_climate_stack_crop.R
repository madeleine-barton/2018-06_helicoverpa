rm(list=ls())

#=================================================================================================
#CLIMATE PROJECTIONS FROM SILO
#=================================================================================================
#Daily miniumum and maximum temperatures extracted from the ACCESS 1.0 model
#model=ACCESS1-0; 
#time=day
#Experiments: historical and rcp85
#sourced at:https://esgf-node.llnl.gov/projects/esgf-llnl/

#packages required:
library(maptools)
library(raster)   
library(rgeos)
library(ncdf4)
library(rgdal)

#--------------------------------------------------------------------------------------
#FUNCTIONS
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
#1. Stack files with same parameter names together, when input files
#are the same parameter for multiple years
#indir = the pathway to the downloaded .nc files"./data/inputs/climate/"
#parameter = a list of the parameters to be conisdered "radiation"
#returns a list of stacks

library(raster)  

stack_params<- function(indir, parameter){
  stacks_combined<-list()
  for (j in(1:length(parameter))){
    filenames<-list.files(path = indir, pattern = parameter[j])
    #These files should be ordered chronologically
    # generate an empty stack to bind to
    inner<-stack()
    for (i in (1:length(filenames))){
      pathname<-paste(indir, filenames[i], sep="")
      #nc <- nc_open(pathname) #call in data - not sure why needed here
      b<- brick(pathname, varname=parameter[j]) #as a rasterbrick
      #plot(b)
      inner<-stack(inner,b)
    }
    stacks_combined[[j]]<-inner
  }
  return(stacks_combined)
}


#2. for a particular raster object, stack it according to a specified extent
#stacks - a list of stacks that are needing to be cropped (raster objsect
#outline - how we are desining the extent - "shape_file", "own_grid"
#region - if shape_file, this is the pathway to where th shape file is
#          if there is a region within the shapefile, include in list format
#region<-c("./data/inputs/climate/raw/gadm36_AUS_shp/gadm36_AUS_1.shp", "Tasmania")
#region<-c("./data/inputs/climate/raw/gadm36_AUS_shp/gadm36_AUS_1.shp")
#          if own_grid - this is the pre-defined lat longs to crop around
#          e.g. c(150, 152, -42, -41)
#unique(myshp$NAME_1)

library(maptools)
library(rgdal)
library(raster)
crop_stack<-function(stacks, outline, region){
  if (outline=="shape_file"){ #we're using a shape file to crop
    myshp <-rgdal::readOGR(region[1]) #call in a shape file
    if(length(region)==2){
      myshp<-subset(myshp,NAME_1==region[2])
    }
    plot(myshp)
    projectExtent(stacks, projection(myshp)) 
    e <- extent(myshp)  #define the extent according to the global map
    myraster.crop <- crop(stacks, e, snap="out") #crop the layers to include only cordinates of shp file
    crop <- setValues(myraster.crop, NA) #all sea areas get NA
    myshp.r <- rasterize(myshp, crop) #raster the new shape file
    xx <- raster::mask(x=myraster.crop, mask=myshp.r)#mask the two rasters
    plot(xx)
    projectExtent(xx, projection(myshp)) 
    #write raster output as new .nc file, only the landareas required
  }else{
    xx <- crop(stacks, region)
  } 
  return(xx)
} 


#3. for a given stack, or raster object, transform the data as required 
#by the parameter specs
#THIS NEEDS MODIFICATIONS+++CHECK ME
library(raster)
transform_stack<- function(filename, parameter){
  var<-unlist(strsplit(filename, "_"))[1]
  if (substr(var, 1, 3)=="tas"){
    cropped_climate <- cropped_climate-273.15 #convert from Kelvin to Celsius
    }else{
      if(substr(var, 1, 4)=="prec"){
        cropped_climate <- cropped_climate-0 #convert to mm per day
      }else{
    } 
      cropped_climate <-0 # if we have any other data - check this
      print("check how to transform the data")
    }
  return(cropped_climate)
}
