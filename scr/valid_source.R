
argv <-commandArgs(TRUE)

if (length(argv) <1)
  stop ("missing arguments")

print(length(argv))
my_dir<-argv[1]
region<-argv[2]
species<-argv[3]
climate<-argv[4]


details<-paste(region, species, climate, sep="_")

##call in the predicted distributions
preds<-read.csv(paste(my_dir, details, ".csv", sep=""))
pred_dist<-preds$dist


##call in the observed distributions
obs<-read.csv(paste(my_dir, speces, "obsevations.csv", sep=""))
##select observations for the region of interest


##bind the observed and predicted distribtuions together, ad spcify which is which

##write file for validation to small_data file

##run the predicted AUC on teh regions???

#print out the stats values??



