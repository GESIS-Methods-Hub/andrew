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

dirname2render=$(dirname ${file2render})
basename2render=$(basename ${file2render})

output_dirname=~/_output/$dirname2render/${basename2render%.*}
output_basename=index.md

mkdir $output_dirname

git --version

git_hash=$(git rev-parse HEAD)

# If git > 2.25
# git_date=$(git log -1 --format="%as")
# else
git_date=$(git log -1 --format=format:%ad --date=format:%Y-%m-%d)

quarto_version=$(quarto --version)

cp $Rmd_file $file2render

sed -i -e '/^output: rmarkdown/d' $file2render

cd $dirname2render

quarto \
    render ${basename2render} \
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
    cp index.md $output_dirname/$output_basename && \
    ~/_docker-scripts/copy-assets.sh $output_dirname
