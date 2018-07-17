#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --mem=5GB
#SBATCH --ntasks=1
#SBATCH --job-name="CC_affects"


# load the R module; change the version if needed
module load R/3.4.4

indir=../data/outputs/array_collated/
region=Tasmania
species=armigera
climate=current,plus3
outdir=../data/outputs/rasters/

Rscript --vanilla CC_affects_source.R ${indir} ${region} ${species} ${climate} ${outdir}


