
#Validation of presence observations, 
#and background points against predicted distribtuions using AUC, and to 
#pROC pacakge.Calls in a dataframe, with lat, lon, preds and obs, with 
#the two latter in binary form.  Returns a dataframe with AUC values
#according to how many background points are used

AUC_valid<-function(df){
  df<-as.data.frame(df)
  #print(typeof(df))
  print(head(df))
  library(pROC)
  bg_number<-c(10, 100, 1000, 10000)
  print(bg_number)
  values<-matrix(ncol=5, nrow=length(bg_number), data=NA)
  print(values)
  for(i in (1:length(bg_number))){
    presences<-subset(df,subset=(df$obs==1))
    #print(df$obs[1])
    background<-df[floor(runif(bg_number[i],1,nrow(df))),]
    #print(background[1])
    background$obs<-0
    stats<-rbind(presences, background)  
    pr.roc<-roc(response = stats$obs, predictor = stats$pred, 
                percent = TRUE, ci = TRUE, of = "se", sp = seq(0, 100, 5), ci.type="shape")
    #plot(pr.roc)
    values[i,1]<-bg_number[i]
    values[i,2]<-auc(pr.roc)
    values[i,3]<-unlist(paste(ci(pr.roc)))[1]
    values[i,4]<-unlist(paste(ci(pr.roc)))[3]
    values[i,5]<-as.numeric(values[i,4])-as.numeric(values[i,2])
  }
  AUC_outs<-as.data.frame(values)
  colnames(AUC_outs)<-c("background_points", "AUC",  "AUC-CI", "AUC+CI", "CI")
  return(AUC_outs) 
}
