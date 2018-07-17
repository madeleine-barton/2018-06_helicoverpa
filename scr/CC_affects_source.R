


#call in list of arguments from "Run_array.sh"
argv <-commandArgs(TRUE)

if (length(argv) <1)
  stop ("missing arguments")

#Define arguments and check by printing to output file
#print(length(argv))
my_dir<-argv[1]
region<-argv[2]
species<-argv[3]
climate<-unlist(strsplit(argv[4],","))# a list of current [1] and future [2] cliamte scenarios, according to filenames
out_dir<-argv[5]
print(climate[1])

#===============================================================================================
#call in current predictions
inname<-paste(region, species, climate[1],sep="_")
print(inname)
current<-read.csv(paste(my_dir, inname, ".csv", sep=""))
print(head(current))

#fall in future scenario predictions
inname<-paste(region, species, climate[2], sep="_")
print(inname)
future<-read.csv(paste(my_dir, inname, ".csv", sep=""))
print(head(future))


#==================================================================================================
#determine how the distribtuions have changed according to the binary measures of dist in the outputs
source('./dist_change.R')
changes<-dist_change(current$dist, future$dist)

#=================================================================================================
#define lat and lon neededn for the raster
lat<-current$lat
lon<-current$lon

#==================================================================================================
#changes in dist - generate raster and write to output file .nc extention
source('./raster_a_df.R')
outname<-paste(region, species, "dist_change",sep="_")
xx<-raster_a_df(as.data.frame(cbind(lat, lon, changes)))
writeRaster(xx,filename=paste(out_dir, outname, ".nc", sep=""), overwrite=TRUE,
            varname="Dchange")

#=================================================================================================
#For later, try writing figures for manusctipt straight to pdf. file for publishing
#DC<- colorRampPalette(colors=c("white","firebrick2", "ivory3", "dodgerblue3"))
#path <- file.path(paste(out_dir, outname inname"C:/Users/mbarton/Desktop/CP.outputs/Figures/Fig2/species_3.change.map.jpg", sep = ""))
#png(file=path, res=300, width=5, height=5, units = "in")
#R1<-raster_a_df(lat, lon, changes)

#plot(R1, main="", xlab="Longitude", ylab = "Latitude", col=DC(4), legend=F)
#extra information for manusctipt plotting
#plot(Africa, add=T, border="black", lwd=0.5)
#legend("bottomleft", legend = "(a)", bty="n", bg = "white",cex=1)
#print("still in figure pathway")
#dev.off()
#print("dev_off success")


print("end_script")
#

