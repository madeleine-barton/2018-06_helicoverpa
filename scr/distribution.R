#Run a function to determine is a species persists in grid cell or not
#call in a df with "voltinism", "heat_stress", and "cold_stress" as column names


distribution<-function(df){
	distribution<-ifelse(((df$voltinism>=1) & (df$heat_stress==0) & (df$cold_stress==0)), 1, 0)
	return(distribution)
}
