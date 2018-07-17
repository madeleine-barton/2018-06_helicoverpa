#Download species occurence records for validation step if current distribution
#currently, two options for databases = Atlas of living Australia, and GBIF
#here, two functions that download data from URLs (need internet connection)
#input a list of the species, and returns a list, each item for the different species

#Function for downloading data from Atlas of Living Australia with ALA4R package
#assuming package is already called in source scripts
ALA_download<-function(spp_list, fields_to_extract){
  inner<-list()
  for (i in spp_list){
    all_records <- occurrences(taxon=paste(i), download_reason_id=4)$data
    all_records <-all_records[all_records$country == "Australia", ]
    all_records<-all_records[,fields_to_extract]
    all_records$DB<-"ALA"
    inner[i]<-all_records
  }
  return(inner)
}


#Function for downloading data from GBIF with rgbif package
#assuming package is already called in source scripts
gbif_download<-function(spp_list, fields_to_extract){
  inner<-list()
  for (spp in spp_list){
    search_res<- occ_search(scientificName = paste(spp), fields=fields_to_extract, return='data',  country = 'AU')
    all_records <- search_res[, fields_to_extract] #reorder the names such that they match with ALA outputs 
    all_records$DB<-"gbif"
    inner[i]<-all_records
  }
 return(inner)
}


