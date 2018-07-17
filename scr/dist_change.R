#A function to determine how a species distribution is likely to 
#change in the future. Takes in 2 vectors:current and predicted
#distribtuions in binary format, with the same locations listed
#in each, and returns a single vector corresponding to each locatin with
#4 output options: "0" always absent; "1" becoming absent; 
#"2" always present and "3" becoming present


dist_change<-function(current, future){
  Dchange<-list()
  for(i in 1:length(current)){
    if((future[i]==1)&(current[i]==1)){### 2 = distribtuions are the same
      Dchange[i]<-2
    }else{
      if((future[i]==0)&(current[i]==1)){### 1 = regions lost under climate change
        Dchange[i]<-1
      }else{
        if((future[i]==0)&(current[i]==0)){### 0 = absent in both climate scenrios
          Dchange[i]<-0
        }else{
          if((future[i]==1)&(current[i]==0)){### 1 = regions gained under climate change
            Dchange[i]<-3
          }}}}
  }
  Dchange<-unlist(Dchange)
  return(Dchange)
}

