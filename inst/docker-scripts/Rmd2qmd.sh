#!/bin/bash
#
# Convert R Markdown to Quarto
#
# Syntax:
#
# Rmd2md.sh github_https github_user_name github_repository_name file2render

github_https=$1
github_user_name=$2
github_repository_name=$3
Rmd_file=$4
file2render=${Rmd_file/Rmd/qmd}

dirname2render=$(dirname ${file2render})
basename2render=$(basename ${file2render})

output_dirname=~/_output/$dirname2render/${basename2render%.*}
output_basename=index.qmd

mkdir --parents $output_dirname

cp $Rmd_file $file2render

sed -i -e '/^output: rmarkdown/d' $file2render

cp $file2render $output_dirname/$output_basename
