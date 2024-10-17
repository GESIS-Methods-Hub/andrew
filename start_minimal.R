# check python settings
library(reticulate)
use_condaenv("base", required = TRUE)
# set wd
setwd("/home/dehnejn/gitlab/andrew")

# load project deps
devtools::load_all()

# hacked the docker rootless with this:
print("setting DOCKER_HOST to rootless (export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock)")
Sys.setenv(DOCKER_HOST = "unix:///run/user/1003/docker.sock")

# run project
andrew::main(source_dir="minimal_example", config_filename = "config_minimal.yaml")

