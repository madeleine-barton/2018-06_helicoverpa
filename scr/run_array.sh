#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --mem=5GB
#SBATCH --ntasks=1
#SBATCH --job-name="DD_simulations"
#SBATCH --array=1-2951

# load the R module; change the version if needed
module load R/3.4.0

clim_indir=../data/inputs/climate/
site_file=../data/inputs/climate/lat_lon_list_Tasmania.csv
spec_file=../data/inputs/sp_physiol/armigera_physiol.csv
#location=$SLURM_ARRAY_TASK_ID
#totsites=3
Rscript --vanilla sim_source_array.R ${clim_indir} max_temp,min_temp ${site_file} ${spec_file} $SLURM_ARRAY_TASK_ID 2951






