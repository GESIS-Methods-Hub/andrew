#!/bin/bash

repo2docker \
    --no-run \
    --user-name methodshub \
    --image-name methodshub/gesis-methods-hub/minimal-example-qmd-rstats:commit \
    --appendix 'RUN curl -s -L $(curl -s https://quarto.org/docs/download/_prerelease.json | grep -oP "(?<=\"download_url\":\s\")https.*amd64\.tar.gz" | head -n 1) -o /tmp/quarto.tar.gz && mkdir ~/opt && tar -C ~/.local -xvzf /tmp/quarto.tar.gz --strip-components=1 && rm /tmp/quarto.tar.gz && R --quiet -e "install.packages(\"rmarkdown\")"' \
    https://github.com/GESIS-Methods-Hub/minimal-example-qmd-rstats

# docker run \
#     --mount type=bind,source=/home/raniere/MethodsHub/raniere-portal/GESIS-Methods-Hub/minimal-example-qmd-rstats,target=/tmp/2methodshub \
#     gesis-methods-hub-minimal-example-qmd-rstats \
#     quarto render index.qmd --to md --output ./index.md

docker run -it \
    --mount type=bind,source=/home/raniere/MethodsHub/raniere-portal/GESIS-Methods-Hub/minimal-example-qmd-rstats,target=/tmp/2methodshub \
    gesis-methods-hub-minimal-example-qmd-rstats \
    /bin/bash