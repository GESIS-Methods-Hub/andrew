# check python settings
library(reticulate)
use_condaenv("base", required = TRUE)
# set wd
setwd("/home/dehnejn/gitlab/andrew")

# load project deps
devtools::load_all()

# run project
andrew::main(source_dir="minimal_example", config_filename = "config_minimal.yaml")

