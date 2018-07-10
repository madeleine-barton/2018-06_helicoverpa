#!/bin/bash

#SBATCH --time=01:00:00
#SBATCH --mem=5GB
#SBATCH --ntasks=1
#SBATCH --name="prep_climate_data"

# load the R module; change the version if needed
module load R/3.4.0

# run R
#cd project_directory
clim_indir=../data/inputs/climate/
site_file=../data/inputs/climate/lat_lon_list_Tasmania.csv
spec_file=../data/inputs/sp_physiol/armigera_physiol.csv
Rscript --vanilla sim_source.R ${clim_indir} max_temp,min_temp ${site_file} ${spec_file}



