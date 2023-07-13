#!/bin/bash
#
# Copy assets
#
# Syntax:
# copy-assets.sh output_dirname

output_dirname=$1

find . -iname '*.bib' -exec cp --parents {} $output_dirname \; && \
    find . -iname '*.jpg' -exec cp --parents {} $output_dirname \; && \
    find . -iname '*.jpeg' -exec cp --parents {} $output_dirname \; && \
    find . -iname '*.png' -exec cp --parents {} $output_dirname \; && \
    find . -iname '*.gif' -exec cp --parents {} $output_dirname \; && \
    find . -iname '*.tif' -exec cp --parents {} $output_dirname \; && \
    find . -iname '*.tiff' -exec cp --parents {} $output_dirname \; && \
    find . -iname '*.pdf' -exec cp --parents {} $output_dirname \; && \
    find . -iname '*.eps' -exec cp --parents {} $output_dirname \;
