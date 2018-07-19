#=================================================================================================
# CROP CLIMATE PROJECTIONS FROM SILO ACCORDING TO DEFINED EXTENT
#=================================================================================================
#gpclibPermit()
#library(maptools)
library(raster)   
#library(rgeos)
#library(ncdf4)
library(rgdal)

#For a particular raster object crop according to a specified extent
#stacks - a list of stacks (or any raster object) to be cropped
#outline - how we are defining the extent - "shape_file", "own_grid"
#region - if shape_file, this is the pathway to where th shape file is
#          if there is a region within the shapefile, include in list format
#region<-c("./data/inputs/climate/raw/gadm36_AUS_shp/gadm36_AUS_1.shp", "Tasmania")
#region<-c("./data/inputs/climate/raw/gadm36_AUS_shp/gadm36_AUS_1.shp")
#          if own_grid - pre-defined lat longs to crop around
#          e.g. c(150, 152, -42, -41)

crop_stack<-function(stacks, outline, region){
  outer_list<-list()
  names_outer<-list()
  if (outline=="shape_file"){ #we're using a shape file to crop
    myshp <-rgdal::readOGR(region[1]) #call in a shape file
    if(length(region)==2){
      state<-subset(myshp, NAME_1==region[2])
      regions<-state$NAME_2[121:150]  ###CHANGE THIS AFTER TROUBLE SHOOTING
      print("subsetting to regional level of shape file")
    }else{
      print("no subsetting of region")
    }
    #plot(myshp)
    print("my_shape_successfully_defined")
    
    for (i in(1:length(stacks))){
      inner<-list()
      names_inner<-list()
      print("in outer loop")
      for (j in(1:length(regions))){
        suburb<-subset(state, NAME_2==regions[j])
        print(suburb$NAME_2)
        e <- extent(suburb)  #define the extent according to the global map
        #print("extent defined")
        if(is.null(intersect(extent(unlist(stacks)[[i]]), e))){
          print("Error")
          next}
        myraster.crop <- crop(unlist(stacks)[[i]], e, snap="out") #crop the layers to include only cordinates of
        #print("cropped to extent")
        crop <- setValues(myraster.crop, NA) #all sea areas get NA
        #print("removed sea")
        myshp.r <- rasterize(suburb, crop) #raster the new shape file
        #print("rasterise the shape object")
        xx <- raster::mask(x=myraster.crop, mask=myshp.r)#mask the two rasters
        #print("mask the raster with the other raster")
        print(minValue(xx)[1])
        if(is.na(minValue(xx)[1])){
                 print("Error")
                 next}
	inner[[j]]<-xx
        names_inner[[j]]<-paste(suburb$NAME_2)
      }
      outer_list[[i]]<-inner[inner!="NULL"]
      names_outer[[i]]<-names_inner[names_inner!="NULL"]
  }
    }else{
    for (i in(1:length(stacks))){
      xx <- crop(unlist(stacks)[[i]], extent(region))
      outer_list[[i]]<-xx
      names_outer[[i]]<-"not_required"
    }
  }
    return(list(outer_list, names_outer))
}
