
#=================================================================================================
#Generate a raster from a dataframe to plot
#=================================================================================================
#using the raster package, turn a dataframe, with lat, lon, and the variable (only and in that
#order), into a spatial raster object that can be plotted and stacked etc.

library(raster)
raster_a_df<-function(df){
  z<-df[,3]
  RR<-as.matrix(cbind(df[,2], df[,1], z), header=TRUE)
  colnames(RR)<-c("y","x","z")
  RDF<-data.frame(RR)
  coordinates(RDF)<-~y+x
  gridded(RDF)<-TRUE
  RDF<-as(RDF, "SpatialGridDataFrame") # to full grid
  rast<-raster(RDF)
  return(rast)
}
