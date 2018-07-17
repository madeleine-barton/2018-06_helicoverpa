
argv <-commandArgs(TRUE)

if (length(argv) <1)
  stop ("missing arguments")

print(length(argv))
my_dir<-argv[1]
print(my_dir)
species<-unlist(strsplit(argv[2],","))
print(species)
database<-unlist(strsplit(argv[3],","))
print(database)

region<-argv[4]

print("length of species")
print(length(species))
#=================================================================================================
#define the species name by Genus_species as strings in a list
print(species)
gen<-seq(1, length(species), by=2)
sp<-seq(2, length(species), by=2)
print(gen)
print(sp)

names<-list()
for (i in(1:(length(species)/2))){
  names[i]<-paste(species[gen[i]], species[sp[i]], sep=" ")
}

#print(names)
#names=(unlist(names))
#print(names)

#=============================================================================================
#Download the datasets according to the database specified in run_valid.sh

#source('./spobs_download.R')

##If ALA is in the list of databases, go for it...
#library(ALA4R)
#ALA_fields_to_extract<-c("scientificName","latitude", "longitude", "year", "month", "eventDate","basisOfRecord")
#if("ALA" %in% database == TRUE){
#  ala_list<-ALA_download(spp_list, ALA_fields_to_extract)
#  }

#...likewise for gbif
#library(rgbif)
#gbif_fields_to_extract<-c('name',"decimalLatitude", "decimalLongitude","year", "month","eventDate", "basisOfRecord")
#spp_list<-names
#if("gbif" %in% database == TRUE){
#  gbif_list<-gbif_download(spp_list, gbif_fields_to_extract)
#}


#and now unlist the data, and combine into species-specific dataframe for writing to file

#=================================================================================================
#map the relevant observations to a raster, and save with predictions

#define prediction pathway and file
pred_name<-paste(region, species[2], "currentdistribution", sep="_")
preds<-(paste('../data/outputs/rasters/', pred_name, ".nc", sep=""))
print("the name of the preds file")
print(preds)

#define obs pathway and filename
inname<-paste(species[2], "obs", sep="_")
print("name of obs file")
print(inname)
obs<-(paste(my_dir, inname, ".csv", sep=""))
print("path to obs")
print(obs)

#map the two together
print("up to mapping")
source('./map_obs.R')
library(ncdf4)
library(raster)
comps<-map_obs(preds, obs)
print(head(comps))

#write.csv(comps, '../data/outputs/Tas_obs_pre.csv')


#===============================================================================================
#push the comparison dataset (predicted and observed, "comps") to calculate AUC value
source('./AUC_valid.R')
AUC_results<-AUC_valid(comps)
print(AUC_results)

#write AUC_ results to file for records
outname<-paste(region, species[2], sep="_")
print(outname)

write.csv(AUC_results, file=paste('../data/outputs/AUC_results_', outname, '.csv', sep=""))

  
print("end_script")










