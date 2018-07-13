#!/bin/bash

#SBATCH --time=00:20:00
#SBATCH --mem=20GB
#SBATCH --ntasks=1
#SBATCH --name=prep_climate_data
# load the R module; change the version if needed
module load R/3.4.0

# run R
#cd project_directory
indir=/OSM/CBR/AF_DATASCHOOL/input/Maddie/2018-06_helicoverpa/data/
trait=voltinism
Rscript --vanilla output_source.R ${indir} ${voltinism}




