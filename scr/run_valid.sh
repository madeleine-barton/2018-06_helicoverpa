#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --mem=5GB
#SBATCH --ntasks=1
#SBATCH --job-name="DD_validations"
#SBATCH --array=1-2951

# load the R module; change the version if needed
module load R/3.4.4

val_indir=../data/inputs/sp_obs/
region=Tasmania
species=armigera

Rscript --vanilla valid_source.R ${val_indir} ${region} ${species}


