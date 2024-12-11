#!/bin/bash
#
# Convert Quarto to Markdown without postrender profile
#
# Syntax:
#
# ipynb2md.sh

echo "starting qmd2md.sh"

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

quarto_version=$(quarto --version)

cd $dirname2render

# Perform Quarto rendering
output=$(quarto render "${basename2render}" \
    --execute \
    --to markdown \
    --output index.md \
    --wrap=none \
    --lua-filter="/home/andrew/_pandoc-filters/licensefield.lua" \
    --metadata "method:true" \
    --metadata "citation:true" \
    --metadata "github_https:${github_https}" \
    --metadata "github_user_name:${github_user_name}" \
    --metadata "github_repository_name:${github_repository_name}" \
    --metadata "docker_image:${docker_image}" \
    --metadata "git_hash:${git_hash}" \
    --metadata "git_date:${git_date}" \
    --metadata "date:${git_date}" \
    --metadata "info_quarto_version:${quarto_version}" \
    --metadata "source_filename:${file2render}" 2>&1) # Capture both stdout and stderr

echo "Quarto render output:"
echo "$output"

# Check if Quarto render succeeded
if [ $? -ne 0 ]; then
    echo "Error: Quarto render failed!"
    exit 1
fi

# Copy the rendered file to the output directory
cp index.md "$output_dirname/$output_basename"
echo "Copied index.md to $output_dirname/$output_basename"

# Run the asset copy script
"${docker_script_root}/copy-assets.sh" "$output_dirname"
echo "Assets copied successfully."