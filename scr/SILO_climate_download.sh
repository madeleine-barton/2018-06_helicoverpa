
#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --mem=1gb
#SBATCH --ntasks=1
#SBATCH --name=SILO_download


#OUTDIR="../data/climate/"
OUTDIR="/OSM/CBR/AF_DATASCHOOL/input/Maddie/2018-06_helicoverpa/data/inputs/climate/SILO/" #set the out directory
#step through the lines in file (defined in the command line) IFS = makes  sure the
#white space at the ends of the lines are not ignored. the while loop makes sure there
#are still lines to be read, and the -n line pipe makes sure the last line in the file is
#read properly, the "-r" prevents backslaches from being inverted (??)
# ---- ask Kerensa how it know which file it should be reading at the input (defined
#in the command line, but nothing listed here...)
#https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable

while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Text read from file: $line"
	URL=`echo $line` #each line is the URL wanted
	POOL=`echo $URL | cut -d '/' -f7 ` #extrat the file name from the URL
	NAME=$OUTDIR$POOL #paste the file name to the directory
	echo $NAME #print out our the directory for checking in command line
	wget ${URL} -O ${NAME} #download the data and save according to the out file
done < "$1" #NOT SURE WHAT THIS DOES

#____________________________________________
#TO RUN FROM COMMAND LINE:
#chmod +c this.file.sh
#./this_file.sh path/to/input_file.txt
#____________________________________________
