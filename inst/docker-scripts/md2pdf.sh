#!/bin/bash
#
# Convert Markdown to PDF
#
# Syntax:
#
# md2pdf.sh

dirname2render=$(dirname ${file2render})
basename2render=$(basename ${file2render})

input_dirname=~/methodshub/$dirname2render/${basename2render%.*}
input_basename=index.md

quarto_version=$(quarto --version)

cd $input_dirname

quarto \
    render ${input_basename} \
    --to pdf \
    --output index.pdf && \
    rm -rf _output
