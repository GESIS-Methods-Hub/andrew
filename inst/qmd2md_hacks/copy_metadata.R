# Load required packages
install.packages("ymlthis", repos = "https://cran.rstudio.com", quietly = TRUE, verbose = FALSE)
install.packages("yaml", repos = "https://cran.rstudio.com", quietly = TRUE, verbose = FALSE)
library(ymlthis)
library(yaml)
library(rmarkdown)

# Specify the file names
input_file <- Sys.getenv("file2render")
output_file <- "index.md"

# Parse YAML metadata from both files
input_yaml <- rmarkdown::yaml_front_matter(input_file)
output_yaml <- rmarkdown::yaml_front_matter(output_file)

# Merge YAMLs with preference for input_file
merged_yaml <- modifyList(output_yaml, input_yaml)

# Convert the merged YAML back to a string format
yaml_str <- as.character(asis_yaml_output(as_yml(merged_yaml)))
yaml_cleaned <- gsub("```yaml\n|\n```", "", yaml_str)

# Read the entire content of the output file
output_content <- readLines(output_file)

# Find the end of the original YAML front matter and skip it
yaml_end <- which(output_content == "---")[2]
body_content <- output_content[(yaml_end + 1):length(output_content)]

# Combine the cleaned YAML metadata and the body content
full_content <- c(yaml_cleaned, "", body_content)

# Write the final content back to the output file
writeLines(full_content, output_file)


# For debugging or viewing
test_file <- "/home/andrew/_qmd2md_hacks/hack_output_1.txt"
file.copy(output_file, test_file, overwrite = TRUE)
