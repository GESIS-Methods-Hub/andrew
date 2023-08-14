#!/bin/bash
#
# Convert Microsoft Office Word 2007 (DOCX) to Markdown
#
# Syntax:
#
# docx2md.sh

if test -f "/opt/quarto/bin/tools/pandoc"
then
    export PANDOC=/opt/quarto/bin/tools/pandoc
else
    export PANDOC=pandoc
fi

dirname2render=$(dirname ${file2render})
basename2render=$(basename ${file2render})

output_dirname=$output_location/$dirname2render/${basename2render%.*}
output_basename=index.md

mkdir --parents $output_dirname

git --version

git_hash=$(git rev-parse HEAD)

# If git > 2.25
# git_date=$(git log -1 --format="%as")
# else
git_date=$(git log -1 --format=format:%ad --date=format:%Y-%m-%d)

pandoc_version=$(${PANDOC} --version | head -n 1 | awk '{print $2}')
quarto_version=$(quarto --version)

cd $dirname2render
pwd
cover_filename=$(find . -name 'cover*' | head -n 1)

if [ -z "$cover_filename" ]
then
echo "Couldn't locate cover* file"
cover_metadata=""
else
echo "Located $cover_filename"
cover_metadata="image:$cover_filename"
fi

${PANDOC} \
    --from docx+styles \
    --to markdown \
    --wrap=none \
    --standalone \
    --extract-media=./ \
    ${cover_metadata:+"--metadata" "$cover_metadata"} \
    --metadata "prefer-html:true" \
    --metadata "guide:true" \
    --metadata "citation: true" \
    --metadata "github_https:${github_https}" \
    --metadata "github_user_name:${github_user_name}" \
    --metadata "github_repository_name:${github_repository_name}" \
    --metadata "git_hash:${git_hash}" \
    --metadata "git_date:${git_date}" \
    --metadata "date:${git_date}" \
    --metadata "info_pandoc_version:${pandoc_version}" \
    --metadata "source_filename:${file2render}" \
    --lua-filter=_pandoc-filters/remove-toc.lua \
    --output index.md \
    ${basename2render} && \
    cp index.md $output_dirname/$output_basename && \
    ${docker_script_root}/copy-assets.sh $output_dirname
