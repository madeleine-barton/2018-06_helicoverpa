
#call in list of arguments from "Run_array.sh"
argv <-commandArgs(TRUE)

if (length(argv) <1)
  stop ("missing arguments")

#Define arguments and check by printing to output file
#print(length(argv))
my_dir<-argv[1]
my_param<-unlist(strsplit(argv[2],","))
species<-argv[4]
my_physiol<-read.csv(paste("../data/inputs/sp_physiol/",species,"_physiol.csv", sep=""))
climate<-argv[7]

#===============================================================================================
#Call in the climate data that has been prepared earlier

#but first stack the parameters together, so that the climate data from the 
#desired points are extracted from the stack list more efficiently
source('./climate_stack.R')
my_stack<-stack_params(my_dir, my_param)
local<-as.numeric(argv[5]) #define the location that we want (array job number)
tot_sites<-as.numeric(as.character(argv[6])) #the total number of array jobs possible
#print(tot_sites)
#read in the list of lat lons that have been generated with run_job, and select number of arrays
region<-argv[3]
pointsfile<-paste(my_dir,"lat_lon_list_",region, ".csv", sep="")
my_points<-read.csv(pointsfile)[(1:tot_sites),] 
#print(nrow(my_points)) #check these for good luck

#===============================================================================================
#call in the list of years that was already saved to file, only the second column is needed
years<-read.csv(file=paste(my_dir,"year_list.csv", sep=""))[,2]
print("the list of years")
print(years)

#===============================================================================================
#Start the simulations, where each location is send separately in the job array list
#so no location loop required here.

source('./helicoverpa_physiol_functions.R')
source('./extract_climate_point_timeseries.R')

RAW_DATA<-matrix() #set up an empty matrix into which the data is stored

#just to be sure we have one site (j) that has been sent from run_array
j=local
print(j)
#for(j in(1:nrow(my_points))){ #this is an artefact from when sites were run in series, keep for reference
#define thermal conditions at the site
temps<-point_timeseries(my_stack, my_param, my_points[j,2], my_points[j,3])
#Ta<-((temps[,1] + temps[,2])/2)
Tmin<-as.numeric(as.character(temps[,2]))
Tmax<-as.numeric(as.character(temps[,1]))
#print("type and example of tmax")
#print(typeof(Tmax))
#print(Tmax[1])
	
#turn daily min and maxs into hourly temperatures, and run checks
#if daily, turn below two lines off and make interval = "day"
source('./clim_daily_to_hourly.R')
Ta<-convert_to_hourly(Tmin, Tmax)
interval<-"hour"  #here, either "day" or "hour"
#print(typeof(Ta))
#print(length(Ta))
#print(Ta[1:25])

#======================================================================================================================
#apply climate change scenario (current of future)
print(climate)
print(interval)
if((climate=="plus3") & (interval=="hour")){
	Ta<-Ta+3
	Tmin<-Tmin+3
	Tmax<-Tmax+3
    }else{
	if((climate=="plus3") & (interval=="day")){
	Tmin<-Tmin+3
	Tmax<-Tmax+3
    }
}

#=========================================================================================================================
#defining initial developmental and physiological conditions of the animal	
init_stage<-1
init_DD<-0
init_gen<-0
#(interval all lower case, affects timing of degree day simulations)
#and the durations the an animal can withstand  heat or cold stress in hours
CTS<-as.numeric(8) #number of hours insect can withstand cold stress **NOT** including current hour (if hourly, otherwise "0")
HTS<-as.numeric(0) #number of hours insect can withstand heat stress **NOT** including current hour (if hourly, otherwise "0")

#=============================================================================================================================
#determine day of year, assuming we are starting on the first of january
library(geosphere)
source('./julian_days.R')
Hem="S"
doy_info<-julian_days(years, Hem, my_points[j,3] )
print(head(doy_info))
#outdir="/OSM/CBR/AF_DATASCHOOL/input/Maddie/2018-06_helicoverpa/"
#write.csv(doy_info,file=paste(outdir,"data/outputs/doy_conditions_.csv", sep=""), row.names=FALSE)
#print("doy_out_good")

#===========================================================================================================================
#Determine if conditions allow for PUPAL diapause or not
if(interval=="hour"){
	doy_info<-doy_info[rep(seq_len(nrow(doy_info)), each=24),]
    }else{
	doy_info=doy_info
  }
#print(doy_info)
environ<-as.data.frame(cbind(doy_info[,(2:3)], Ta))
environ<-as.data.frame(environ)
print(head(environ))
print(typeof(environ))
source('./diapause_conditions.R')
diapause_or_not<-diapause_cond(environ, my_physiol, interval)
print(head(diapause_or_not))
print(diapause_or_not$diapause)
#============================================================================================================================
#set up the output matrix into which data is filled
output<-matrix(ncol=6, nrow=length(Ta), data="NA") # the length will vary depending if daily or hourly Ta
colnames(output)<-c("new_stage", "new_gen", "RT_DD", "heat_stress", "cold_stress", "diapause")

	#start cycling through the timepoints at the location
	for (i in(1:length(Ta))){
        if(i==1){
           curr_DD<-Lactin_DD(Ta[i], init_stage, my_physiol) #either Lactin_DD, or current_DD
           RT_DD<-acc_DD(init_DD, curr_DD)
           outs<-Lactin_trans(interval, RT_DD, init_stage, init_gen, my_physiol) #either Lactin_trans or linear trans
           output[i,(1:3)]<-unlist(outs)
	         output[i,4]<-heat_stress(Ta[i], init_stage, my_physiol) #if hourly, first argument here is Ta[i], otherwise Tmax[i]
	         output[i,5]<-cold_stress(Ta[i], init_stage, my_physiol)
	         output[i,6]<-0 #never start the simulation in diapause
         }else{
           if((as.numeric(output[i-1,1])==3) & (diapause_or_not$diapause[i]==1)){
             curr_DD<-0 #either Lactin_DD, or current_DD - diapause means no development
             RT_DD<-acc_DD(init_DD, curr_DD) #but hold the previous days development stage
             #outs<-Lactin_trans(interval, RT_DD, as.numeric(output[i-1,1]), as.numeric(output[i-1,2]), my_physiol)
             output[i,(1:3)]<-unlist(as.numeric(output[i-1,1]), as.numeric(output[i-1,2]), RT_DD)
             output[i,4]<-0 #diapause buffers from heat stress
             output[i,5]<-0 #diapause buffers from cold stress
             output[i,6]<-1 #we're in diapause, so holding previous hours development
           }else{
            curr_DD<-Lactin_DD(Ta[i], as.numeric(output[i-1,1]), my_physiol)#either Lactin_DD, or current_DD
            RT_DD<-acc_DD(as.numeric(output[i-1,3]), curr_DD)
            outs<-Lactin_trans(interval, RT_DD, as.numeric(output[i-1,1]), as.numeric(output[i-1,2]), my_physiol)
	          output[i,(1:3)]<-unlist(outs)
	              if(i>(HTS+1)){
                   output[i,4]<-heat_stress(as.numeric(Ta[(i-HTS):i]), as.numeric(output[i-1,1]), my_physiol)
                }else{
                   output[i,4]<-heat_stress(as.numeric(Ta[i]), as.numeric(output[i-1,1]), my_physiol)
                }
	              if(i>(CTS+1)){
	                output[i,5]<-cold_stress(as.numeric(Ta[(i-CTS):i]), as.numeric(output[i-1,1]), my_physiol)
	              }else{
                  output[i,5]<-cold_stress(Ta[i], as.numeric(output[i-1,1]), my_physiol)
	              }
	         output[i,6]<-0 #we're not in diapause, development as per usual
   }} #end diapausing loop
}#end days after 1 loop
#end all days cycling loop

print(my_physiol[1,5])
#Collate site output, and extra information into a manageable output dataframe	
site_out<-as.data.frame(output)
#site_out$Tmax<-temps[,1] #if hourly, don't need the daily tmins and tmaxs
#site_out$Tmin<-temps[,2] #if hourly, don't need the daily tmins and tmaxs
site_out$Ta<-Ta
site_out$SITE<-j
site_out$lat<-my_points[j,3]
site_out$lon<-my_points[j,2] 
site_out<-as.data.frame(cbind(site_out, doy_info))
RAW_DATA<-site_out
print(nrow(RAW_DATA))
print(min(as.numeric(as.character(RAW_DATA$diapause))))
print(max(as.numeric(as.character(RAW_DATA$diapause))))
#===================================================================================================
#Call the DD_output_summaries.R file to collate the site output raw data into a mappable output
source('./DD_output_summaries.R')
generations<-voltinism(as.data.frame(RAW_DATA)) #calculate the number of generations
heat_stresses<-heat_deaths(as.data.frame(RAW_DATA)) #number of heat stress days
cold_stresses<-cold_deaths(as.data.frame(RAW_DATA)) #number of cold stress days
diapause_duration<-diapause_hours(as.data.frame(RAW_DATA)) #total number of hours in diapause
print(head(heat_stresses))
print(head(diapause_duration))
output_sum<-as.data.frame(cbind(generations, heat_stresses, cold_stresses, diapause_duration))

#==================================================================================================
#Depending on the performance traits, determine whther occupancy or not
source('./distribution.R')
dist<-distribution(output_sum)
output_sum<-cbind(output_sum, dist)
print(head(output_sum))

#===================================================================================================
#Refine the output name so that files are listed in order from 1 to 99 (need to add 100-1000)
loc_name<-ifelse((local<=9), paste("0",local,sep=""), paste(local))
outname<-paste(region, species, climate, "site", loc_name, sep="_")
print(outname)

#==================================================================================================
#write the raw data, and the summary outputs to file, here, on the bowen drive (big_data shortcut)
outdir="/OSM/CBR/AF_DATASCHOOL/input/Maddie/2018-06_helicoverpa/" 
write.csv(RAW_DATA,file=paste(outdir,"data/outputs/raw/",outname,".csv", sep=""), row.names=FALSE) 
print("raw_out_good") 
write.csv(output_sum,file=paste(outdir,"/data/outputs/array_summaries/summary_", outname, ".csv", sep=""), row.names=FALSE) 
print("summary_out_good") 

#==================================================================================================
print("end_sims")
