#!/bin/bash
#
# Convert Microsoft Office Word 2007 (DOCX) to Markdown
#
# Syntax:
#
# docx2md.sh github_https github_user_name github_repository_name file2render

github_https=$1
github_user_name=$2
github_repository_name=$3
file2render=$4

dirname2render=$(dirname ${file2render})
basename2render=$(basename ${file2render})

output_dirname=~/_output
output_basename=${basename2render%.*}.md

git --version

git_hash=$(git rev-parse HEAD)

# If git > 2.25
# git_date=$(git log -1 --format="%as")
# else
git_date=$(git log -1 --format=format:%ad --date=format:%Y-%m-%d)

cd $dirname2render

pandoc \
    --from docx+styles \
    --to markdown \
    --standalone \
    --extract-media=./ \
    --metadata="prefer-html:true" \
    --metadata="guide:true" \
    --metadata="citation: true" \
    --metadata="github_https:${github_https}" \
    --metadata="github_user_name:${github_user_name}" \
    --metadata="github_repository_name:${github_repository_name}" \
    --metadata="git_hash:${git_hash}" \
    --metadata="git_date:${git_date}" \
    --metadata "date:${git_date}" \
    --metadata="source_filename:${file2render}" \
    --lua-filter=_pandoc-filters/remove-toc.lua \
    --output index.md \
    ${basename2render}  && \
    cp index.md $output_dirname/$output_basename && && \
    ~/_docker-scripts/copy-assets.sh $output_dirname
