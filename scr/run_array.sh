#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --mem=5GB
#SBATCH --ntasks=1
#SBATCH --job-name="DD_simulations"
#SBATCH --array=1-2951

# load the R module; change the version if needed
module load R/3.4.0

clim_indir=../data/inputs/climate/
region=Tasmania
species=armigera
climate=current
#location=$SLURM_ARRAY_TASK_ID
#totsites=3
Rscript --vanilla sim_source_array.R ${clim_indir} max_temp,min_temp ${region} ${species} $SLURM_ARRAY_TASK_ID 2951 ${climate}






