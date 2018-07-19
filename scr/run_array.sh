#!/bin/bash

#SBATCH --time=01:00:00
#SBATCH --mem=3GB
#SBATCH --ntasks=1
#SBATCH --job-name="DD_simulations"
#SBATCH --array=1-30680

# load the R module; change the version if needed
module load R/3.4.0

clim_indir=/OSM/CBR/AF_DATASCHOOL/input/Maddie/2018-06_helicoverpa/data/inputs/climate/
region=NSW
species=armigera
climate=current
#location=$SLURM_ARRAY_TASK_ID
#totsites=3
Rscript --vanilla sim_source_array.R ${clim_indir} max_temp,min_temp ${region} ${species} $SLURM_ARRAY_TASK_ID 30680 ${climate}






