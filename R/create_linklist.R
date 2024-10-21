library(quanteda)
library(dplyr)

create_linklist <- function(content_contributions_filename) {

  # Load the JSON data with tags from the file
  data_with_tags <- fromJSON(content_contributions_filename)

  # Initialize a list to store counts of links for each tag
  tag_count <- list()
  tag_link_groups <- list()

  # Iterate over the rows of the table (data_with_tags)
  for (i in 1:nrow(data_with_tags)) {
    entry <- data_with_tags[i, ]
    web_address <- entry$web_address
    filename <- entry$filename

    # Split the 'tags' column into a list of individual tags (remove extra spaces)
    tags <- entry$tags[[1]]

    # Skip entries if web_address or filename is NA or NULL
    if (!is.null(web_address) & !is.na(web_address) & !is.null(filename) & !is.na(filename)) {

      # Extract the last part of the web_address to use as the title of the link
      link_title <- basename(web_address)

      # For each tag, group the link under the tag
      for (tag in tags) {

        # Check if the tag already exists in the list, if not, initialize it
        if (is.null(tag_link_groups[[tag]])) {
          # Create a new entry for this tag if it doesn't exist
          tag_link_groups[[tag]] <- list()
        }

        # Append the link (with title) to the existing list for that tag
        tag_link_groups[[tag]] <- c(tag_link_groups[[tag]], list(c(link_title, web_address)))

        # Update the count for each tag
        if (is.null(tag_count[[tag]])) {
          tag_count[[tag]] <- 1
        } else {
          tag_count[[tag]] <- tag_count[[tag]] + 1
        }
      }
    }
  }

  # Sort tags by the number of entries and select the top 5
  sorted_tags <- names(sort(unlist(tag_count), decreasing = TRUE))[1:5]

  # Only retain the top 5 tags in the final grouped list
  top_tag_link_groups <- tag_link_groups[sorted_tags]

  # Generate the markdown content for the Quarto file
  markdown_content <- "## Top Five Computed Topics\n"

  for (tag in sorted_tags) {
    # Start a new list group for each tag
    markdown_content <- paste0(markdown_content, "### ", tag, "\n\n")
    markdown_content <- paste0(markdown_content, "::: {list-group}\n")

    # Add all the links associated with this tag
    for (link_info in top_tag_link_groups[[tag]]) {
      title <- link_info[[1]]  # Use the last part of the web_address as the visible part of the link
      link <- link_info[[2]]   # Use the constructed link
      markdown_content <- paste0(markdown_content, "- [", title, "](", link, ")\n")
    }

    # End the list group
    markdown_content <- paste0(markdown_content, ":::\n\n")
  }

  # Write the markdown content to a file named topics.md
  writeLines(markdown_content, "topics.md")


}
