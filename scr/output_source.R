
argv <-commandArgs(TRUE)

if (length(argv) <1)
  stop ("missing arguments")

in_dir<-argv[1]
trait<-argv[2]

filenames<-list.files(path = paste(in_dir,"outputs/array_summaries/", sep=""), pattern = ".csv")
print(paste(in_dir,"outputs/array_summaries/", sep=""))
print(filenames)

#df<-read.csv(paste(in_dir, "outputs/array_summaries/",filenames[1], sep=""))
#print(head(df))

for (i in(1:length(filenames))){
	if (i==1){ 
	df<-read.csv(paste(in_dir, "outputs/array_summaries/",filenames[i], sep=""), header=TRUE)
	}else{
	df1<-read.csv(paste(in_dir, "outputs/array_summaries/",filenames[i], sep=""), header=TRUE)
	df<-rbind(df, df1)
	}}

print(head(df))

source('./raster_a_df.R')
xx<-raster_a_df(df[,(2:4)])
print("raster_good")
xx
print(typeof(xx))
library(raster)

write.csv(df,"../data/outputs/array_collated/2018_07_10_summary_output_punctigera.csv", row.names=FALSE)
print("summary_out_good")
print(colnames(df[4]))

writeRaster(xx,filename="../data/outputs/rasters/2018_07_10_trial_voltinism_punctigera.nc", overwrite=TRUE,
varname=colnames(df[4]))

print("end_script")

