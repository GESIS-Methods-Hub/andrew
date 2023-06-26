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

PANDOC=/opt/quarto/bin/tools/pandoc

git --version

git_hash=$(git rev-parse HEAD)

# If git > 2.25
# git_date=$(git log -1 --format="%as")
# else
git_date=$(git log -1 --format=format:%ad --date=format:%Y-%m-%d)

$PANDOC \
    --from docx \
    --to markdown \
    --standalone \
    --metadata="prefer-html:true" \
    --metadata="guide:true" \
    --metadata="appendix-cite-as:display" \
    --metadata="github_https:${github_https}" \
    --metadata="github_user_name:${github_user_name}" \
    --metadata="github_repository_name:${github_repository_name}" \
    --metadata="git_hash:${git_hash}" \
    --metadata="git_date:${git_date}" \
    --metadata "date:${git_date}" \
    --metadata="source_filename:${file2render}" && \
    --output index.md \
    ${file2render} \
    cp index.md _output/index.md && \
    find . -iname '*.jpg' -exec cp --parents {} _output \; && \
    find . -iname '*.jpeg' -exec cp --parents {} _output \; && \
    find . -iname '*.png' -exec cp --parents {} _output \; && \
    find . -iname '*.gif' -exec cp --parents {} _output \; && \
    find . -iname '*.tif' -exec cp --parents {} _output \; && \
    find . -iname '*.tiff' -exec cp --parents {} _output \; && \
    find . -iname '*.pdf' -exec cp --parents {} _output \; && \
    find . -iname '*.eps' -exec cp --parents {} _output \;