
#Define incoming arguments
argv <-commandArgs(TRUE)

if (length(argv) <1)
  stop ("missing arguments")

in_dir<-argv[1]
region<-argv[2]
species<-argv[3]
climate<-argv[4]

#==================================================================================================
#Call in files in the in_dir folder and generate a list
details<-paste(region, species, climate, sep="_")
filenames<-list.files(path = paste(in_dir,"outputs/array_summaries/", sep=""), pattern = details)
#print(paste(in_dir,"outputs/array_summaries/", sep=""))
#print(filenames)

#Loop through the files in the list and rbind as it goes
for (i in(1:length(filenames))){
	if (i==1){ 
	df<-read.csv(paste(in_dir, "outputs/array_summaries/",filenames[i], sep=""), header=TRUE)
	}else{
	df1<-read.csv(paste(in_dir, "outputs/array_summaries/",filenames[i], sep=""), header=TRUE)
	df<-rbind(df, df1)
	}}
print(head(df))

#write the resulting summary dataframe to output file
out_dir<-"../data/outputs/array_collated/"
write.csv(df, paste(out_dir, details,".csv", sep=""), row.names=FALSE)
print("summary_out_good")

#=============================================================================================
###generate rasters for plotting results for each trait, collated by site
source('./raster_a_df.R')
raster_out<-"../data/outputs/rasters/"
#Voltinism - generate raster and write to output file .nc extention
library(raster)
xx<-raster_a_df(df[,(2:4)])
writeRaster(xx,filename=paste(raster_out, details, "_generations.nc", sep=""), overwrite=TRUE,
varname=colnames(df[4]))

#Heat_stress - generate raster and write to output file .nc extention
xx<-raster_a_df(df[,c(2,3,5)])
writeRaster(xx, filename=paste(raster_out, details, "_heat_stress.nc", sep=""), overwrite=TRUE,
varname=colnames(df[5]))

#Cold_stress - generate raster and write to output file .nc extention
xx<-raster_a_df(df[,c(2,3,6)])
writeRaster(xx,filename=paste(raster_out, details, "_cold_stress.nc", sep=""), overwrite=TRUE,
varname=colnames(df[6]))

#Distribution - generate raster and write to output file .nc extention
xx<-raster_a_df(df[,c(2,3,8)])
writeRaster(xx,filename=paste(raster_out, details, "_distribution.nc", sep=""), overwrite=TRUE,
varname=colnames(df[8]))

#Diapause - generate raster and write to output file .nc extention
xx<-raster_a_df(df[,c(2,3,7)])
xx
writeRaster(xx, filename=paste(raster_out, details, "_diapause_hours.nc", sep=""), overwrite=TRUE,
varname=colnames(df[7]))


#=============================================================================================================

print("end_script")

