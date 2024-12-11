print("startign qmd2md hacks")

# Load required packages
install.packages("ymlthis", repos = "https://cran.rstudio.com", quietly = TRUE, verbose = FALSE)
install.packages("yaml", repos = "https://cran.rstudio.com", quietly = TRUE, verbose = FALSE)
library(ymlthis)
library(yaml)
library(rmarkdown)

# Specify the file names
output_file <- "index.md"       # Output Quarto file
citation_file <- "CITATION.cff" # Path to CITATION.cff file

# Check if the CITATION.cff file exists
if (!file.exists(citation_file)) {
  # If CITATION.cff does not exist, terminate without making changes
  message("CITATION.cff file not found. No changes made to the output file.")
  quit(save = "no")
}

# Parse the CITATION.cff file
citation_yaml <- read_yaml(citation_file)

# Extract the URL from CITATION.cff or use a default value
url_field <- NULL
if (!is.null(citation_yaml$identifiers)) {
  url_field <- citation_yaml$identifiers[[1]]$value
}
url <- ifelse(!is.null(url_field), url_field, "https://kodaqs-toolbox.gesis.org/")

# Generate the desired citation metadata
citation_metadata <- list(
  citation = list(
    type = "document",
    title = citation_yaml$title,
    author = lapply(citation_yaml$authors, function(author) {
      list(name = paste(author$`given-names`, author$`family-names`))
    }),
    issued = format(as.Date(citation_yaml$`date-released`), "%Y"),
    accessed = "urldate",  # Placeholder for the access date
    `container-title` = "KODAQS_Toolbox",  # Updated container title
    publisher = "GESIS – Leibniz Institute for the Social Sciences",
    URL = url  # Use parsed URL or fallback
  )
)

# Parse YAML metadata from the output file
output_yaml <- rmarkdown::yaml_front_matter(output_file)

# Merge output metadata with the new citation metadata
merged_yaml <- modifyList(output_yaml, citation_metadata)

# Convert the merged YAML back to a string format
yaml_str <- as.character(asis_yaml_output(as_yml(merged_yaml)))
yaml_cleaned <- gsub("```yaml\n|\n```", "", yaml_str)

# Read the entire content of the output file
output_content <- readLines(output_file)

# Find the end of the original YAML front matter and skip it
yaml_end <- which(output_content == "---")[2]
body_content <- output_content[(yaml_end + 1):length(output_content)]

# Combine the cleaned YAML metadata and the body content
full_content <- c("---", yaml_cleaned, "---", "", body_content)

# Write the final content back to the output file
writeLines(full_content, output_file)

# For debugging or viewing
test_file <- "/home/andrew/_qmd2md_hacks/hack_output.txt"
file.copy(output_file, test_file, overwrite = TRUE)
