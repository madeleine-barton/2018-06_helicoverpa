

argv <-commandArgs(TRUE)

if (length(argv) <1)
  stop ("missing arguments")

print(length(argv))
my_dir<-argv[1] 
my_param<-unlist(strsplit(argv[2],","))[1]
my_outline<-argv[3]
my_region<-unlist(strsplit(argv[4],","))
my_region[2]<-gsub(":", " ", my_region[2]) #insert spaces in region name is needed
my_outdir<-"/OSM/CBR/AF_DATASCHOOL/input/Maddie/2018-06_helicoverpa/data/inputs/climate/"
out_region<-argv[5]

#==============================================================================================================
#Check the parameteres have been loaded correctly
print(my_param)
print(my_outline)
print(my_region)

#==============================================================================================================
#stack the climate files in chronological order, according to the variable
source("./climate_stack.R")
climate_stacks<-stack_params(my_dir, my_param)
print(climate_stacks)
print("climate_successfully_stacked")

#==============================================================================================================
#generate and write out a list of the years included in the simulations, attined from the file names
#this informatio is used later in the simulations
years<-year_list(my_dir, my_param)
print(years)
yrs<-as.data.frame(years)
write.csv(yrs, paste(my_outdir, out_region, "_year_list.csv", sep=""))

#===============================================================================================================
#crop the climate data according to the extent defined by either a shape file, or own lat/lons
source("./climate_crop.R")
cropped_stacks<-crop_stack(climate_stacks, my_outline, my_region)
print("climate_successfully_cropped")

#=============================================================================================================
#write out the raster stacks in our list to file, to be called in by the simulation script
#first need to define the out_region name (no spaces allowed.
out_region<-argv[5]
for (i in(1:length(my_param))){
        print("in writing out loop")
	for (j in(1:length(cropped_stacks[[1]][[1]]))){
	print("in suburb list")
        suburb<-(unlist(cropped_stacks[[2]])[j]) 
	print("suburb name defined")
        suburb<-gsub(" ", "...", suburb)
	out_name<-paste(out_region,suburb, my_param[i], sep="_")
	name<-paste(my_outdir, out_name, ".nc", sep="")
        print(name)
	print(unlist(cropped_stacks[[1]][[i]][j]))
        print(typeof(stack(unlist(cropped_stacks[[1]][[i]][j]))))
	rast<-stack(unlist(cropped_stacks[[1]][[i]][j]))
        if(nrow(rast)==1){next}
	if(ncol(rast)==1){next}
        writeRaster(rast, filename=name, overwrite=TRUE, varname=my_param[i])
        print("raster_written")
}}
print("completed printing climate_data to file")
#==============================================================================================================
#generate a list of the lat/lon coordinates within our extent, to be iterated through as array jobs in the sim
source("./generate_coord_list.R")
xx<-list(unlist(cropped_stacks[[1]][[1]]), unlist(cropped_stacks[[2]][[1]]))
df_latlons<-generate_coords(xx)

write.csv(df_latlons, paste(my_outdir, "lat_lon_list","_", out_region, ".csv", sep=""))
print(nrow(df_latlons))


#=============================================================================================================
print("end_script")
