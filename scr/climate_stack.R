
#packages required:
library(raster)   
library(ncdf4)

#Stack files with same parameter names together, when input files

stack_params<- function(indir, parameter){
  stacks_combined<-list()
  print(indir)
  print("started_stacking_function")
  print(str(parameter[1]))
  for (j in(1:length(parameter))){
    XX<-paste(parameter[j])
    print(XX)
    filenames<-list.files(path = indir, pattern = XX)
    print(filenames)
    #These files should be ordered chronologically
    # generate an empty stack to bind to
    inner<-stack()
    for (i in (1:length(filenames))){
      pathname<-paste(indir, filenames[i], sep="")
      print(pathname)
      #nc <- nc_open(pathname) #call in data - not sure why needed here
      b<- brick(pathname, varname=parameter[j]) #as a rasterbrick
      summary(b)
      inner<-stack(inner,b)
    }
    stacks_combined[[j]]<-inner
  }
  return(stacks_combined)
}

#stack_params(my_dir, my_param)
