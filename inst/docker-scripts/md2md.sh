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

quarto \
    render ${basename2render} \
    --to markdown \
    --output index.md-tmp \
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
    --metadata="source_filename:${file2render}" && \
    cp index.md-tmp $output_dirname/$output_basename && \
    ~/_docker-scripts/copy-assets.sh $output_dirname
