#!/bin/bash
#
# Convert Markdown to Markdown
#
# Syntax:
#
# md2ipynb.sh github_https github_user_name github_repository_name file2render

github_https=$1
github_user_name=$2
github_repository_name=$3
file2render=$4

cp $file2render _output/index.qmd
