#!/usr/local/bin/Rscript
source("/app/utils.R")

dht::greeting()

withr::with_message_sink("/dev/null", library(dplyr))
withr::with_message_sink("/dev/null", library(digest))
withr::with_message_sink("/dev/null", library(knitr))
# withr::with_message_sink("/dev/null", library(sf))


doc <- "
      Usage:
        entrypoint.R [-h | --help] [-v | --version] [-i <filename> | --input-file <filename>] [-o <output-prefix> | --output-file-prefix=<output-prefix>] [-f <fields> | --include-deid-fields=<fields>] [--force] [--shiny]

         
      Options:
        -h --help             Show available parameters.
        -v --version          Show version.
        -i --input-file <filename>
                              Specify input csv file.
        --force               Overwrite existing files if they exist.
        -o --output-file-prefix <output-prefix>
                              Specify output prefix ( By default, the prefix is `output`, which will generate output.log, output-phi.csv, output-deid.csv).
        -f --include-deid-fields <fields>
                              Specify list of fields to include in output.
                              Dafault fields: 'id','date','precision','geocode_result','fraction_assisted_income','fraction_high_school_edu','median_income','fraction_no_health_ins','fraction_poverty','fraction_vacant_housing','dep_index','drivetime_selected_center','nearest_center_pcgc','drivetime_pcgc','version'
                              
        --shiny               Start shiny server on port 3838.                      
        

      "
opt <- docopt::docopt(doc)


# Access the parsed arguments
input_file <- opt[["--input-file"]]
output_prefix <- opt[["--output-file-prefix"]]
include_deid_fields <- opt[["--include-deid-fields"]]
force <- opt[["--force"]]

if (is.null(input_file) & ! (opt$shiny)){
  stop("Input csv is missing. Please specify a .csv address file")
}




if (is.null(output_prefix)){output_prefix = 'output'}

log_filename = paste0(output_prefix, "-log.txt")
out_filename = paste0(output_prefix, "-with-phi.csv")
deid_filename = paste0(output_prefix, "-deid.csv")

if (!force & (file.exists(log_filename) | file.exists(out_filename) | file.exists(deid_filename)) & !opt$shiny){
  stop("One or more of the output files already exist. 
       \nPlease specify a different output prefix with `-o` or `--output-file-prefix` argument or use `--force` to overwrite existing output.
       \nExiting program...")
}

args_list = list(filename = input_file, output_prefix = output_prefix, score_threshold = 0.5, include_deid_fields = include_deid_fields)

if (!is.null(args_list$filename)){
  result = rdcrn_run(args_list)
}


# Handle version option
if (opt$version | opt$ver) {
  cat("Version: geoocoder_shiny_0.0.1\n")
  q(status = 0)
}


if (opt$shiny) {
  shiny::runApp(appDir="/app",host='0.0.0.0',port=3838)
}



