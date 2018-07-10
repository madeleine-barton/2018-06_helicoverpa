argv <-commandArgs(TRUE)

if (length(argv) <1)
  stop ("missing arguments")

print(length(argv))
my_dir<-argv[1]
my_param<-unlist(strsplit(argv[2],","))
my_points<-read.csv(argv[3])[(1:20),] #for testing, specify here how many points to use
my_physiol<-read.csv(argv[4])

#print(my_dir)
#print(my_param)
#print(head(my_points))
#print(head(my_physiol))
#print("number_of_sites")
print(nrow(my_points))

source('./climate_stack.R')
my_stack<-stack_params(my_dir, my_param)
#print(my_stack)

source('./helicoverpa_physiol_functions.R')
source('./extract_climate_point_timeseries.R')

RAW_DATA<-matrix()


for(j in(1:nrow(my_points))){
	temps<-point_timeseries(my_stack, my_param, my_points[j,2], my_points[j,3])
	Ta<-((temps[,1] + temps[,2])/2)
#	print(temps)

	init_stage<-1
	init_DD<-0
	init_gen<-0
	interval<-"Day"

	output<-matrix(ncol=3, nrow=length(Ta), data="NA")
	colnames(output)<-c("new_stage", "new_gen", "RT_DD")

	for (i in(1:length(Ta))){
         if(i==1){
           curr_DD<-current_DD(Ta[i], init_stage, my_physiol)
           RT_DD<-acc_DD(init_DD, curr_DD)
           outs<-stage_trans(interval, RT_DD, init_stage, init_gen, my_physiol)
           output[i,]<-unlist(outs)
	   #print("day_one")
	   #print(j)
         }else{
           curr_DD<-current_DD(Ta[i], as.numeric(output[i-1,1]), my_physiol)
           RT_DD<-acc_DD(as.numeric(output[i-1,3]), curr_DD)
           outs<-stage_trans(interval, RT_DD, as.numeric(output[i-1,1]), as.numeric(output[i-1,2]), my_physiol)
           output[i,]<-unlist(outs)
		  }
} #end day loop(i)
  #print("all_sites_done")
	
   site_out<-as.data.frame(output)
   #print(head(site_out))
   print(j)
   site_out$Tmin<-temps[,1] 
  site_out$Tmax<-temps[,2]
  site_out$Ta<-Ta
  site_out$SITE<-j
  site_out$lat<-my_points[j,3]
  site_out$lon<-my_points[j,2] 
 
 if (j==1){
    RAW_DATA<-site_out
    }else{
    RAW_DATA<-rbind(RAW_DATA, site_out)
    }

   print(nrow(RAW_DATA))

}#end location loop (j)

#print(head(RAW_DATA))

source('./DD_output_summaries.R')
output_sum<-output_summary(as.data.frame(RAW_DATA))
#print(head(output_sum))

df<-as.data.frame(output_sum)[,(2:4)]
source('./raster_a_df.R')


xx<-raster_a_df(df)
print("raster_good")
#xx
#print(typeof(xx))
library(raster)

write.csv(RAW_DATA,"../data/outputs/raw/2018_07_09_trial_output_puntigera.csv" )
print("raw_out_good")
write.csv(output_sum,"../data/outputs/2018_07_09_summary_output_puntigera.csv" )
print("summary_out_good")
print(colnames(df[3]))
writeRaster(xx,filename="../data/outputs/rasters/2018_07_09_trial_voltinism_punctiera.nc", overwrite=TRUE, 
varname=colnames(df[3]))

print("end_script")
