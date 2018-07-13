
#=================================================================================================
#HELICOVERPA DEGREE_DAY CALCULATIONS, STAGE TRANSITIONS, and GENERATION TALLIES
#=================================================================================================
#Take daily tempeatures or hourly, and determine the degree day units according to thermal
#physiology of the species

#1a. calculate degree days based on current temperature
#a) Ta = temperature
#b) LDT = lower development threshold, depending on the current stage
#c) CTmax = where development stops, also depending on the threshold

current_DD<-function(Ta, cur_stage, sp_data){
  LDT<-sp_data[cur_stage,5]
  CTmax<-sp_data[cur_stage,6]
  DD<-ifelse(((Ta>LDT) & (Ta<CTmax)),(Ta-LDT),0)
  return(DD)
}


#1b. calculate degree days based on current temperature
#a) Ta = temperature
#b) LDT = lower development threshold, depending on the current stage
#c) CTmax = where development stops, also depending on the threshold

Lactin_DD<-function(Ta, cur_stage, sp_data){
  pho<-sp_data[cur_stage,11]
  CTmax<-sp_data[cur_stage,12]
  delta<-sp_data[cur_stage,13]
  gamma<-sp_data[cur_stage,14]
  DD<-exp(pho * Ta) - exp(pho * CTmax - (CTmax - Ta)/delta) + gamma
  return(DD)
}


#2. Accumulate degree day units through time
#a) previous DD units
#b) current degree day units
acc_DD<-function(prev_DD, curr_DD){
  cum_DD<-prev_DD + curr_DD
  return(cum_DD)
}

#3a. stage transitions with linear regression model:
#a) interval = time interval at which model is cycling - hour or day
#a) RT_DD accumulated degree days on this hour
#b) cur_stage (as defined by previous hour)
#d) cur_gen the generation as defined by the previous hour
#e) sp_data the species physiology data file

#for each hour, determine is we've completed develpment in this stage, and then
#transition through to the next one if so, adding a generation onto the tally
#returns a list of integers, that need to be unlisted into an output file, and then called
# on the following hour of the model

linear_trans<-function(interval, RT_DD, cur_stage, cur_gen, sp_data){
  K <- sp_data[cur_stage,4]
  if (interval == "hour"){
    K<=K*24
    }
  if(K<RT_DD){
     new_stage=cur_stage+1
  }else{
    new_stage=cur_stage
  }
  if(new_stage>nrow(sp_data)){
    new_stage=1
    RT_DD=0
    new_gen=cur_gen+1
  }else{
    new_stage=new_stage
    RT_DD=RT_DD
    new_gen=cur_gen
  }
  return(list(new_stage, new_gen, RT_DD))
}



#3b. stage transitions with Lactin model:
#a) interval = time interval at which model is cycling - hour or day
#a) RT_DD accumulated degree days on this hour
#b) cur_stage (as defined by previous hour)
#d) cur_gen the generation as defined by the previous hour
#e) sp_data the species physiology data file


#for each hour, determine is we've completed develpment in this stage, and then
#transition through to the next one if so, adding a generation onto the tally
#returns a list of integers, that need to be unlisted into an output file, and then called
# on the following hour of the model

Lactin_trans<-function(interval, RT_DD, cur_stage, cur_gen, sp_data){
  if (interval == "hour"){
    RT_DD<=RT_DD/24
    }
  if(1<RT_DD){ #if we've completed development of this stage
     new_stage=cur_stage+1
     RT_DD=0
  }else{
    new_stage=cur_stage
    RT_DD=RT_DD
  }
  if(new_stage>nrow(sp_data)){
    new_stage=1
    RT_DD=0
    new_gen=cur_gen+1
  }else{
    new_stage=new_stage
    RT_DD=RT_DD
    new_gen=cur_gen
  }
  return(list(new_stage, new_gen, RT_DD))
}


#4. Determine if heat stressed or not 

heat_stress<-function(Tmax, cur_stage, sp_data){
  CTmax<-sp_data[cur_stage,12]
  HS<-ifelse((Tmax>CTmax), 1 ,0)
  return(as.numeric(HS))
}


#5. Determine if cold stressed or not

cold_stress<-function(Tmin, cur_stage, sp_data){
  CTmin<-sp_data[cur_stage,5]
  CS<-ifelse((Tmin<CTmin), 1 ,0)
  return(as.numeric(CS))
}


