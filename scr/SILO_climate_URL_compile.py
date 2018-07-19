import argparse

# Geneate a list of all the files, based on year and variable
# to request from SILO https://silo.longpaddock.qld.gov.au/
# the list of filenames are written to an output file
# and this is then called with a bash script and "wget"
# This setup follows scripts from data school biopython:
# bar823@pearcey-login:/flush1/bar823/scripts/extracting_vcf>


# Loop over years and  variables to generate URL and write to output file

def SILO_URLs(start, finish, variables, outfile):
    """download files and append to list, to write out"""
    with open(outfile, 'w') as out:
        for year in range(int(start), int(finish)):
            for var in range(len(variables)):
                end_URL = variables[var] + "/" + str(year) + "." + variables[var] + ".nc"
                start_URL = "https://s3-ap-southeast-2.amazonaws.com/silo-open-data/annual/"
                my_URL = start_URL + end_URL
                out.write("%s\n" % my_URL)


def main():
        SILO_data = argparse.ArgumentParser()
        SILO_data.add_argument("start", help = "the FLOAT year to begin downloaded files, eg. 1995")
        SILO_data.add_argument("finish", help = "the FLOAT final year of the downloaded files, eg.2000 ")
        SILO_data.add_argument("parmList", help = "a LIST of climate parameters, sep',' eg.temp,RF")
	SILO_data.add_argument("output", help = "defines the STR file directory and name of output")
        args = SILO_data.parse_args()
        start = args.start
        finish = args.finish
        variables = args.parmList.split(",")
	outfile = arg.output

if __name__ == "__main__":
	main()
