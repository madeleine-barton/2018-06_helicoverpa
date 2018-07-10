#=================================================================================================
#Generate a list of lat lons from a stacked raster file
#=================================================================================================
#Generate a list of the co-ordinates from a raster object (saved to an .nc file)
#by providing the infile ("./folder/to/file/file.nc" or a stack)
#returns a dataframe wit lat lon in order
#packages required:
library(raster)   

generate_coords<-function(stack){
	if(typeof(stack)==typeof("filepath")){
	    x<-unlist(strsplit(stack, "/")) #adjust splitting and indices where needed
	    par<-x[length(x)]
	    vname<-unlist(strsplit(par,"\\."))[1]  #remove .nc extention from filename
	    b<- brick(stack, varname=vname) #as a rasterbrick
	    p<- as.data.frame(rasterToPoints(b[[1]]))
	    colnames(p)<-c("lon","lat","value")
	    return(p[,1:2])
	}else{
	    p<- as.data.frame(rasterToPoints(stack[[1]]))
            colnames(p)<-c("lon","lat","value")
            return(p[,1:2])
  }
}
  
