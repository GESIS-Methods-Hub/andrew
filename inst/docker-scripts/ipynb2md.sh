#!/bin/bash
#
# Convert Jupyter Notebook to Markdown
#
# Syntax:
#
# ipynb2md.sh github_https github_user_name github_repository_name file2render

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

quarto_version=$(quarto --version)

quarto \
    render ${file2render} \
    --to md \
    --metadata "prefer-html:true" \
    --template "_templates/methods_hub.md" \
    --output index.md \
    --variable "github_https:${github_https}" \
    --variable "github_user_name:${github_user_name}" \
    --variable "github_repository_name:${github_repository_name}" \
    --variable "git_hash:${git_hash}" \
    --variable "git_date:${git_date}" \
    --variable "quarto_version:${quarto_version}" \
    --variable "source_filename:${file2render}" && \
    cp index.md _output/index.md && \
    find . -iname '*.jpg' -exec cp --parents {} _output \; && \
    find . -iname '*.jpeg' -exec cp --parents {} _output \; && \
    find . -iname '*.png' -exec cp --parents {} _output \; && \
    find . -iname '*.gif' -exec cp --parents {} _output \; && \
    find . -iname '*.tif' -exec cp --parents {} _output \; && \
    find . -iname '*.tiff' -exec cp --parents {} _output \; && \
    find . -iname '*.pdf' -exec cp --parents {} _output \; && \
    find . -iname '*.eps' -exec cp --parents {} _output \;