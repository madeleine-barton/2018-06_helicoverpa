#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --mem=1gb
#SBATCH --ntasks=1
#SBATCH --name=CMIP5_download

cd /OSM/CBR/AF_DATASCHOOL/input/Maddie/helicoverpa/
~/helicoverpa/wget-20180404051323.sh


