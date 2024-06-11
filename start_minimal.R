# check python settings
library(reticulate)
use_condaenv("base", required = TRUE)
# set wd
setwd("/home/dehnejn/gitlab/andrew")

# load project deps
devtools::load_all()

# set R logginglevel
logger::log_threshold(logger::DEBUG)
#logger::log_threshold(logger::INFO)

# run project
andrew::main(source_dir="minimal_example")

