argv <-commandArgs(TRUE)

if (length(argv) <1)
  stop ("missing arguments")

print(length(argv))
my_dir<-argv[1]
my_param<-unlist(strsplit(argv[2],","))
my_physiol<-read.csv(argv[4])
local<-as.numeric(argv[5])
print(local)
tot_sites<-as.numeric(as.character(argv[6]))
print(tot_sites)
my_points<-read.csv(argv[3])[(1:tot_sites),] #for testing, specify here how many points to use
print(nrow(my_points))


#print(my_dir)
#print(my_param)
#print(head(my_points))
#print(head(my_physiol))
#print("number_of_sites")

source('./climate_stack.R')
my_stack<-stack_params(my_dir, my_param)
print(my_stack)

source('./helicoverpa_physiol_functions.R')
source('./extract_climate_point_timeseries.R')

RAW_DATA<-matrix()

j=local
print(j)
#for(j in(1:nrow(my_points))){
	temps<-point_timeseries(my_stack, my_param, my_points[j,2], my_points[j,3])
	Ta<-((temps[,1] + temps[,2])/2)
	print(temps)

	init_stage<-1
	init_DD<-0
	init_gen<-0
	interval<-"Day"

	output<-matrix(ncol=5, nrow=length(Ta), data="NA")
	colnames(output)<-c("new_stage", "new_gen", "RT_DD", "heat_stress", "cold_stress")

	for (i in(1:length(Ta))){
        if(i==1){
           curr_DD<-current_DD(Ta[i], init_stage, my_physiol)
           RT_DD<-acc_DD(init_DD, curr_DD)
           outs<-stage_trans(interval, RT_DD, init_stage, init_gen, my_physiol)
           output[i,(1:3)]<-unlist(outs)
	   output[i,4]<-heat_stress(Ta[i], init_stage, my_physiol)
	   output[i,5]<-cold_stress(Ta[i], init_stage, my_physiol)
	   #print("day_one")
	   #print(j)
         }else{
           curr_DD<-current_DD(Ta[i], as.numeric(output[i-1,1]), my_physiol)
           RT_DD<-acc_DD(as.numeric(output[i-1,3]), curr_DD)
           outs<-stage_trans(interval, RT_DD, as.numeric(output[i-1,1]), as.numeric(output[i-1,2]), my_physiol)
	   output[i,(1:3)]<-unlist(outs)
           output[i,4]<-heat_stress(Ta[i], init_stage, my_physiol)
           output[i,5]<-cold_stress(Ta[i], init_stage, my_physiol)
             }
} #end day loop(i)
  #print("all_sites_done")
	
   site_out<-as.data.frame(output)
   #print(head(site_out))
   #print(j)
   site_out$Tmin<-temps[,1] 
   site_out$Tmax<-temps[,2]
   site_out$Ta<-Ta
   site_out$SITE<-j
   site_out$lat<-my_points[j,3]
   site_out$lon<-my_points[j,2] 
 
   RAW_DATA<-site_out
   print(nrow(RAW_DATA))
 
source('./DD_output_summaries.R')
generations<-voltinism(as.data.frame(RAW_DATA))
heat_stresses<-heat_deaths(as.data.frame(RAW_DATA))
cold_stresses<-cold_deaths(as.data.frame(RAW_DATA))

output_sum<-as.data.frame(cbind(generations, heat_stresses[4], cold_stresses[4]))

print(colnames(output_sum))

print(head(output_sum))

loc_name<-ifelse((local<=9), paste("0",local,sep=""), paste(local))
outname<-paste("punctigera_array_trial_JOB_", loc_name, sep="")
print(outname)

outdir="/OSM/CBR/AF_DATASCHOOL/input/Maddie/2018-06_helicoverpa/" 
write.csv(RAW_DATA,file=paste(outdir,"data/outputs/raw/",outname,".csv", sep=""), row.names=FALSE) 
print("raw_out_good") 
write.csv(output_sum,file=paste(outdir,"/data/outputs/array_summaries/summary_", outname, ".csv", sep=""), row.names=FALSE) 
print("summary_out_good") 

print("end_sims")
