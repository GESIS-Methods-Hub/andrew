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

git --version

git_hash=$(git rev-parse HEAD)

# If git > 2.25
# git_date=$(git log -1 --format="%as")
# else
git_date=$(git log -1 --format=format:%ad --date=format:%Y-%m-%d)

quarto \
    convert ${file2render} \
    --output index.ipynb && \
    cp index.ipynb _output/
