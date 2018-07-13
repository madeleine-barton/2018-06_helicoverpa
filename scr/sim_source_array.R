
#call in list of arguments from "Run_array.sh"
argv <-commandArgs(TRUE)

if (length(argv) <1)
  stop ("missing arguments")

#Define arguments and check by printing to output file
print(length(argv))
my_dir<-argv[1]
my_param<-unlist(strsplit(argv[2],","))
my_physiol<-read.csv(argv[4])

#===============================================================================================
#Call in the climate data that has been prepared earlier

#but first stack the parameters together, so that the climate data from the 
#desired points are extracted from the stack list more efficiently
source('./climate_stack.R')
my_stack<-stack_params(my_dir, my_param)
print(my_stack)
local<-as.numeric(argv[5]) #define the location that we want (array job number)
tot_sites<-as.numeric(as.character(argv[6])) #the total number of array jobs possible
print(tot_sites)
#read in the list of lat lons that have been generated with run_job, and select number of arrays
my_points<-read.csv(argv[3])[(1:tot_sites),] 
print(nrow(my_points)) #check these for good luck

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
	Ta<-((temps[,1] + temps[,2])/2)
        Tmin<-as.numeric(as.character(temps[,2]))
	Tmax<-as.numeric(as.character(temps[,1]))
	print("type and example of tmax")
	print(typeof(Tmax))
	print(Tmax[1])
	print(typeof(Ta))
#define initial stages on the first day of simulation 
	init_stage<-1
	init_DD<-0
	init_gen<-0
	interval<-"Day"
#set up the output matrix into which data is filled
	output<-matrix(ncol=5, nrow=length(Ta), data="NA")
	colnames(output)<-c("new_stage", "new_gen", "RT_DD", "heat_stress", "cold_stress")
#start cycling through the timepoints at the location
	for (i in(1:length(Ta))){
        if(i==1){
           curr_DD<-Lactin_DD(Ta[i], init_stage, my_physiol) #either Lactin_DD, or current_DD
           RT_DD<-acc_DD(init_DD, curr_DD)
           outs<-Lactin_trans(interval, RT_DD, init_stage, init_gen, my_physiol) #either Lactin_trans or linear trans
           output[i,(1:3)]<-unlist(outs)
	   output[i,4]<-heat_stress(Tmax[i], init_stage, my_physiol)
	   output[i,5]<-cold_stress(Tmin[i], init_stage, my_physiol)
         }else{
           curr_DD<-Lactin_DD(Ta[i], as.numeric(output[i-1,1]), my_physiol)#either Lactin_DD, or current_DD
           RT_DD<-acc_DD(as.numeric(output[i-1,3]), curr_DD)
           outs<-Lactin_trans(interval, RT_DD, as.numeric(output[i-1,1]), as.numeric(output[i-1,2]), my_physiol)
	   output[i,(1:3)]<-unlist(outs)
           output[i,4]<-heat_stress(as.numeric(Tmax[i]), as.numeric(output[i-1,1]), my_physiol)
           output[i,5]<-cold_stress(Tmin[i], as.numeric(output[i-1,1]), my_physiol)
            }
} #end day loop(i)

#Collate site output, and extra information into a manageable output dataframe	
site_out<-as.data.frame(output)
site_out$Tmax<-temps[,1] 
site_out$Tmin<-temps[,2]
site_out$Ta<-Ta
site_out$SITE<-j
site_out$lat<-my_points[j,3]
site_out$lon<-my_points[j,2] 
 
RAW_DATA<-site_out
print(nrow(RAW_DATA))

#===================================================================================================
#Call the DD_output_summaries.R file to collate the site output raw data into a mappable output
source('./DD_output_summaries.R')
generations<-voltinism(as.data.frame(RAW_DATA)) #calculate the number of generations
heat_stresses<-heat_deaths(as.data.frame(RAW_DATA)) #number of heat stress days
cold_stresses<-cold_deaths(as.data.frame(RAW_DATA)) #number of cold stress days
print(head(heat_stresses))
output_sum<-as.data.frame(cbind(generations, heat_stresses, cold_stresses))

#==================================================================================================
#Depending on the performance traits, determine whther occupancy or not
source('./distribution.R')
dist<-distribution(output_sum)
output_sum<-cbind(output_sum, dist)
print(head(output_sum))

#===================================================================================================
#Refine the output name so that files are listed in order from 1 to 99 (need to add 100-1000)
loc_name<-ifelse((local<=9), paste("0",local,sep=""), paste(local))
outname<-paste("armigera_array_trial_JOB_", loc_name, sep="")
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
