#!/bin/bash

#SBATCH --time=00:20:00
#SBATCH --mem=20GB
#SBATCH --ntasks=1
#SBATCH --name=prep_climate_data
# load the R module; change the version if needed
module load R/3.4.0

# run R
#cd project_directory
shape_info=../data/inputs/climate/shape_files/gadm36_AUS_shp/gadm36_AUS_1.shp,Tasmania
Rscript --vanilla practice_source.R ../data/inputs/climate/SILO/  max_temp,min_temp shape_file ${shape_info}


