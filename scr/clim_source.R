

argv <-commandArgs(TRUE)

if (length(argv) <1)
  stop ("missing arguments")

print(length(argv))
my_dir<-argv[1] 
my_param<-unlist(strsplit(argv[2],",")) 
my_outline<-argv[3]
my_region<-unlist(strsplit(argv[4],","))
my_outdir<-"../data/inputs/climate/"

print(my_param)
print(my_outline)
print(my_region)

source("./climate_stack.R")
climate_stacks<-stack_params(my_dir, my_param)
print(climate_stacks)
print("climate_successfully_stacked")

source("./climate_crop.R")

cropped_stacks<-crop_stack(climate_stacks, my_outline, my_region)

print("climate_successfully_cropped")

for (i in(1:length(my_param))){
  name<-paste(my_outdir, my_param[i], my_region[2], ".nc", sep="")
  writeRaster(unlist(cropped_stacks)[[i]], filename=name, overwrite=TRUE, varname=my_param[i])
}

source("./generate_coord_list.R")
df_latlons<-generate_coords(unlist(cropped_stacks)[[1]])
write.csv(df_latlons, paste(my_outdir, "lat_lon_list","_", my_region[2], ".csv", sep=""))
print(nrow(df_latlons))
