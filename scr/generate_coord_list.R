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
     if((typeof(stack)=="list")){
       for (j in (1:length(stack))){
         new_dat<- as.data.frame(rasterToPoints(stack[[1]][[j]]))
         suburb<-paste(unlist(stack[[2]][[j]]))
         suburb<-gsub(" ", "...", suburb)
         new_dat$region<-paste(suburb)
        if(j==1){
          p<-new_dat
        }else{
          p<-rbind(p,new_dat)
        } 
         }
         colnames(p)<-c("lon","lat","value", "region")
         p[order(p$lon, p$lat),]
         p<-p[,c(1:2,ncol(p))]
         colnames(p)<-c("lon","lat" ,"region")
         return(p)
        }else{
         p<- as.data.frame(rasterToPoints(stack[[1]]))
         colnames(p)<-c("lon","lat","value")
         return(p[,1:2])
      }
    }
}

 
