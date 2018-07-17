#mapping_obs
#A function for mapping species observations onto a raster - need
#to call in teh predicted distribtuion, as the observation data are
#not evenly gridded.... create an empty raster according to the
#dimensions of the predicted map, and then rasterise the observation
#records onto this grid, moving them slightly so that they can be mapped
#returns a dataframe with, lat, lon, preds, and obs

#here, preds is the path and file name leading to the .nc file that's been generated
#by the output_source script
#obs is the path and file name of the obvservation records, both defined in 
#valid_source.R

map_obs<-function(preds, obs){
#first call in the current distribtuion onto which points are mapped
  library(ncdf4) 
  library(raster)
  print(preds)
  b<-brick(preds)
  print("predictions are in") 
  print(preds) 
 #plot(b) 

  #now read in the species observatin poits, and remove missing data
  df1<-read.csv(obs)
  print(obs)
  print("obs are in")
  df1$occ<-1
  df<-na.omit(as.data.frame(cbind(df1$longitude, df1$latitude, df1$occ)))
  colnames(df)<-c("lon", "lat", "occ")
  
  #turn the species obs into a matrix so it can be plotted onto empty raster (r)
  mat<-as.matrix(df)
  e <- extent(b)
  r <- raster(e, ncol=ncol(b), nrow=nrow(b))
  x <- rasterize(mat[, 1:2], r, mat[,3], fun=max)
  #plot(x, add=TRUE) #for checking in R
  
  #stack the predictions and obs together, and write to data.frame
  stacker<-stack(b,x)
  new_data<-rasterToPoints(stacker)
  colnames(new_data)<-c("lon", "lat", "pred", "obs")
  new_data[is.na(new_data)] <- 0

  return(new_data)
}
