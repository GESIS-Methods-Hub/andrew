#!/bin/bash
#
# Convert Jupyter Notebook to Quarto
#
# Syntax:
#
# ipynb2md.sh github_https github_user_name github_repository_name file2render

github_https=$1
github_user_name=$2
github_repository_name=$3
file2render=$4

dirname2render=$(dirname ${file2render})
basename2render=$(basename ${file2render})

output_dirname=~/_output/$dirname2render/${basename2render%.*}
output_basename=index.qmd

mkdir $output_dirname

cd $dirname2render

quarto \
    convert ${basename2render} \
    --output index.qmd && \
    cp index.qmd $output_dirname/$output_basename
