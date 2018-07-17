#!/bin/bash

#SBATCH --time=01:00:00
#SBATCH --mem=2GB
#SBATCH --ntasks=1
#SBATCH --job-name="DD_validations"

# load the R module; change the version if needed
module load R/3.4.4

val_dir=../data/inputs/sp_obs/
species=Helicoverpa,armigera,Helicoverpa,punctigera
database=ALA,gbif
region=Tasmania

Rscript --vanilla valid_source.R ${val_dir} ${species} ${database} ${region}


