#!/bin/bash
#
# Convert Markdown to Markdown
#
# Syntax:
#
# md2md.sh

dirname2render=$(dirname ${file2render})
basename2render=$(basename ${file2render})

output_dirname=~/_output/$dirname2render/${basename2render%.*}
output_basename=index.md

mkdir --parents $output_dirname

git --version

git_hash=$(git rev-parse HEAD)

# If git > 2.25
# git_date=$(git log -1 --format="%as")
# else
git_date=$(git log -1 --format=format:%ad --date=format:%Y-%m-%d)

quarto_version=$(quarto --version)

cd $dirname2render

# README.md does NOT have YAML headers.
# If processing a file without YAML headers,
#
# 1. shift the heading level
# 2. provide name of the author
if [[ $(head -n 1 ${basename2render} | grep -e '---' | wc -l) = 0 ]]
then
echo ${basename2render} does NOT have a YAML header!
shift-heading-level='--shift-heading-level-by=-1'
fallback_author="--metadata='author:$(git log -1 --format=format:%aN)'"
else
echo ${basename2render} has a YAML header!
shift_heading_level='--shift-heading-level-by=0'
fallback_author=''
fi


quarto \
    render ${basename2render} \
    --to markdown \
    --output index.md-tmp \
    ${shift_heading_level} \
    ${fallback_author} \
    --metadata="prefer-html:true" \
    --metadata="method:true" \
    --metadata="citation: true" \
    --metadata="github_https:${github_https}" \
    --metadata="github_user_name:${github_user_name}" \
    --metadata="github_repository_name:${github_repository_name}" \
    --metadata="docker_image:${docker_image}" \
    --metadata="git_hash:${git_hash}" \
    --metadata="git_date:${git_date}" \
    --metadata "date:${git_date}" \
    --metadata="quarto_version:${quarto_version}" \
    --metadata="source_filename:${file2render}" && \
    cp index.md-tmp $output_dirname/$output_basename && \
    ~/_docker-scripts/copy-assets.sh $output_dirname
