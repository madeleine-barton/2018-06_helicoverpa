#!/bin/bash

#SBATCH --time=01:00:00
#SBATCH --mem=20GB
#SBATCH --ntasks=1
#SBATCH --name=prep_climate_data
# load the R module; change the version if needed
module load R/3.4.0

# run R
#cd project_directory
shape_info=../data/inputs/climate/shape_files/gadm36_AUS_shp/gadm36_AUS_2.shp,New:South:Wales
clim_indir=/OSM/CBR/AF_DATASCHOOL/input/Maddie/2018-06_helicoverpa/data/inputs/climate/SILO/

Rscript --vanilla clim_source.R ${clim_indir}  max_temp,min_temp shape_file ${shape_info} NSW


