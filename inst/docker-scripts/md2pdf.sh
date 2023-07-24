#!/bin/bash
#
# Convert Markdown to PDF
#
# Syntax:
#
# md2pdf.sh

dirname2render=$(dirname ${file2render})
basename2render=$(basename ${file2render})

input_dirname=${basename2render%.*}
input_basename=index.md

cd ~/andrew/$input_dirname

quarto --version

quarto \
    render $input_basename \
    --to pdf \
    --output index.pdf
