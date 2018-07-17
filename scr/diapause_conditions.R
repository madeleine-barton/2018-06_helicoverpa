#a function to determine if the conditions are right for
#diapause. Takes in 2 dataframe - one for the environmental conditions, 
#including temperature, photoperiod and season (increasing or decreasing
#daylengths), amd another defining the cues that push the pupae
#(only stage of dormancy for now) commence and terminate diapause.
#interval - dictates whether we are running on daily of hourly timesteps,
#and thus for how long we step back to consider the average temperatures over
#the previous week (or however long it takes to induce/terminate diapause)




diapause_cond<-function(environ, cues, interval){
  print(colnames(environ))
  df<-as.data.frame(cbind(environ, matrix(ncol=1, nrow=nrow(environ), data=0)))
  colnames(df)<-c("photophase", "season", "Ta", "diapause")  #give the dataframe column names (avoid confusion!!!)
  print(colnames(df))
 #set the cues for the animal to be used in the following loops
 #Diapause restricted to pupae for now (row 3), but change to "current stage"
 #if dormance in other life-history stages occurs 
  DL_ind<-as.numeric(cues[3,16])     
  DL_term<-as.numeric(cues[3,17])
  season_ind<-cues[3,18]
  season_term<-cues[3,19]
  Ta_ind<-as.numeric(cues[3,20])     
  Ta_term<-as.numeric(cues[3,21])
  
 temp<-list()
  for (i in(1:nrow(df))){
  #DL<-as.numeric(df$photophase[i])
  #season<-as.numeric(df$season[i])
  if(interval=="hour"){
    if (i>((24*7)+1)){
      temp[i]<-mean(df$Ta[(i-(24*7)):i])
    }else{
      temp[i]<-mean(df$Ta[1:i])
    }
   }else{
     if (i>(7+1)){
       temp[i]<-mean(df$Ta[(i-7):i])
     }else{
       temp[i]<-mean(df$Ta[1:i])
     }
   }
  }
 temp<-unlist(temp)
 print(DL_ind)
 print(DL_term)
 print(Ta_ind)
 print(Ta_term)
# print(DL)
 print(temp[1:50])
 print(season_ind)
 print(season_term)
#determining whether the physical conditions are condusive 
#or not to diapause - irrespective of whether we are already in it or not
#1=yes, diapause
#0=no, keep developing

df$diapause[1]<-0 #never start the simulation in diapause
 for (i in(2:nrow(df))){
   DL<-as.numeric(df$photophase[i])
   season<-df$season[i]
   TA<-temp[i]
   if((season=="Autumn")&(df$diapause[i-1]==1)){
     df$diapause[i]<-1
   }else{
   if (season_ind=="no_cue"){ 
  #if the increasing/decreasing photoperiod pattern doesn't matter for induction
  #i.e. they can enter diapasue after winter solstice, but  needs to be spring
  #to come out of diapause
    if((DL<DL_ind) & (TA<Ta_ind)){ 
      df$diapause[i]<-1
    }else{
      if((season=="Spring")&(DL<DL_term) & (TA<Ta_term)){ 
        df$diapause[i]<-1
      }else{
        df$diapause[i]<-0 
    }
  }
  }else{
    if((season=="Autumn") & (DL<DL_ind) & (TA<Ta_ind)){ #has to be be autumn, low temps and short days
      df$diapause[i]<-1
    }else{
      if((season=="Spring") & (DL<DL_term) & (TA<Ta_term)){ #has to be spring, low temps, still short days
        df$diapause[i]<-1
      }else{
        df$diapause[i]<-0
      }}
  }#end if induction before./after winter soltstice
 }#end checking previous hour in autumn
}#end timestep loop
 return(df)
}#end function

