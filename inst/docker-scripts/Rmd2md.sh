#!/bin/bash
#
# Convert R Markdown to Markdown
#
# Syntax:
#
# Rmd2md.sh github_https github_user_name github_repository_name file2render

github_https=$1
github_user_name=$2
github_repository_name=$3
Rmd_file=$4
file2render=${Rmd_file/Rmd/qmd}

git --version

git_hash=$(git rev-parse HEAD)

# If git > 2.25
# git_date=$(git log -1 --format="%as")
# else
git_date=$(git log -1 --format=format:%ad --date=format:%Y-%m-%d)

quarto_version=$(quarto --version)

cp $Rmd_file $file2render

sed -i -e '/^output: rmarkdown/d' $file2render

quarto \
    render ${file2render} \
    --to markdown \
    --output index.md \
    --metadata="prefer-html:true" \
    --metadata="method:true" \
    --metadata="citation: true" \
    --metadata="github_https:${github_https}" \
    --metadata="github_user_name:${github_user_name}" \
    --metadata="github_repository_name:${github_repository_name}" \
    --metadata="git_hash:${git_hash}" \
    --metadata="git_date:${git_date}" \
    --metadata "date:${git_date}" \
    --metadata="quarto_version:${quarto_version}" \
    --metadata="source_filename:${Rmd_file}" && \
    cp index.md _output/index.md && \
    find . -iname '*.bib' -exec cp --parents {} _output \; && \
    find . -iname '*.jpg' -exec cp --parents {} _output \; && \
    find . -iname '*.jpeg' -exec cp --parents {} _output \; && \
    find . -iname '*.png' -exec cp --parents {} _output \; && \
    find . -iname '*.gif' -exec cp --parents {} _output \; && \
    find . -iname '*.tif' -exec cp --parents {} _output \; && \
    find . -iname '*.tiff' -exec cp --parents {} _output \; && \
    find . -iname '*.pdf' -exec cp --parents {} _output \; && \
    find . -iname '*.eps' -exec cp --parents {} _output \;