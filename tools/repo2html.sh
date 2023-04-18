#!/bin/bash

repo2docker \
    --no-run \
    --image-name gesis-methods-hub-minimal-example-qmd-rstats \
    --appendix 'RUN curl -s -L $(curl -s https://quarto.org/docs/download/_prerelease.json | grep -oP "(?<=\"download_url\":\s\")https.*amd64\.tar.gz" | head -n 1) -o /tmp/quarto.tar.gz && mkdir ~/opt && tar -C ~/.local -xvzf /tmp/quarto.tar.gz --strip-components=1' \
    https://github.com/GESIS-Methods-Hub/minimal-example-qmd-rstats