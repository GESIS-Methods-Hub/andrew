#!/bin/bash
#
# Convert Markdown to PDF
#
# Syntax:
#
# md2pdf.sh

dirname2render=$(dirname ${file2render})
basename2render=$(basename ${file2render})

input_dirname=$dirname2render/${basename2render%.*}
input_basename=index.md

cd ~/andrew/$input_dirname

quarto check

cat > _quarto.yml <<EOF
format:
  pdf:
    pdf-engine: lualatex
    papersize: a4
    geometry:
      - top=25mm
      - bottom=20mm
      - left=25mm
      - right=25mm
    fontsize: '10'
    classoption:
      - DIV=10
      - numbers=noendperiod
    include-in-header:
      - text: |
          \usepackage{luatexja}
EOF
ls
quarto \
    render $input_basename \
    --to pdf \
    --output index.pdf

rm _quarto.yml
