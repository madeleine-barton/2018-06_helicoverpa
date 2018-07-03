import argparse
import SILO_climate_URL_compile as SUcomp

def main():
	SILO_data = argparse.ArgumentParser()
	SILO_data.add_argument("start", help = "the first year")
	SILO_data.add_argument("end", help = "the final year")
	SILO_data.add_argument("parms", help = "LIST of parameters, temp,prec")
	SILO_data.add_argument("output", help = "the directory to where list is written")
	args = SILO_data.parse_args()
	begin = args.start
	end = args.end
	my_parms = args.parms.split(",")
	out_file = args.output
	#run the SILO_URLs in the SILO_climate_URL_compile_script
	SUcomp.SILO_URLs(begin, end, my_parms, out_file)
	###run the scripts that takes the URL list and downloads the data
	##run the (R?) script that stacks the .nc files togethers into bricks
	##run the (R) script that subsets the .stacks into the desired extent
	##run the R script that transforms the data into SI units (depending on parameters)
	## .nc files then ready to use in microcliate model...!


if __name__ == "__main__":
	main()

