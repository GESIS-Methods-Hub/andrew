library(quanteda)
library(dplyr)

create_linklist <- function(json_data) {

  data <- fromJSON(json_data, simplifyDataFrame = FALSE)

  # Initialize empty vectors for storing keywords and links
  keywords <- c()
  keyword_links <- c()

  # Iterate over each top-level collection
  for (i in seq_along(data)) {
    collection <- data[[i]]

    # Combine title, subtitle, and abstract to extract keywords
    text_data <- paste(collection$title, collection$subtitle, collection$abstract, collapse = " ")

    # Create a corpus and tokenize the combined text data
    corpus <- corpus(text_data)
    tokens <- tokens(corpus, remove_punct = TRUE)

    # Create a document-feature matrix without stopwords (dfm_remove replaces dfm's remove argument)
    dfm <- dfm(tokens, tolower = TRUE)
    dfm <- dfm_remove(dfm, stopwords("en"))

    # Extract keywords using dfm and topfeatures (limit to top 10 relevant keywords)
    top_keywords <- names(topfeatures(dfm, n = 10))  # Top 10 keywords

    # Append these keywords to the keywords vector
    keywords <- c(keywords, top_keywords)

    # Check if the collection has a content_set (second-level) that is not empty
    if (is.list(collection$content_set) && length(collection$content_set) > 0) {

      # Iterate over the second-level content_set
      for (j in seq_along(collection$content_set)) {
        nested_collection <- collection$content_set[[j]]

        # If the nested collection is valid, check for third-level web addresses
        if (is.list(nested_collection)) {
          if (!is.null(nested_collection$web_address) &&
            !is.null(nested_collection$filename) &&
            !is.na(nested_collection$web_address) &&
            !is.na(nested_collection$filename)) {

            # Remove the protocol ('https://' or 'http://') but keep 'github.com'
            root_link <- sub("^https?://", "/", nested_collection$web_address)

            # Remove the '.git' suffix from the web address
            root_link <- gsub(".git", "", root_link)

            # Replace 'hub.com' with '/github.com'
            root_link <- gsub("hub.com", "/github.com", root_link)

            # Remove the file extension from filename (e.g., 'index.ipynb' -> 'index')
            file_name <- sub("\\.[a-zA-Z0-9]+$", "", nested_collection$filename)

            # Construct the full link with `/` as the root and correct path format
            link <- paste0(root_link, "/", file_name, "/")

            # Append the title and the link (using title as visible text)
            if (!is.na(nested_collection$title)) {
              keyword_links <- c(keyword_links, list(c(nested_collection$title, link)))
            }
          }
        }
      }
    }
  }

  # Initialize an empty string for the markdown content
  markdown_content <- "## Keywords and Links\n"

  # Create a list to hold links for each keyword
  keyword_link_groups <- list()

  # Initialize a list to store counts of links for each keyword
  keyword_count <- list()

  # Group links by keywords and ensure no NA/NULL values are added (limit to 10 keywords)
  for (i in seq_along(keywords)) {
    keyword <- keywords[i]

    # Skip NA and NULL keywords
    if (!is.na(keyword) & !is.null(keyword)) {
      link_info <- keyword_links[i]
      title <- link_info[[1]]  # Use the title as the visible part of the link
      link <- link_info[[2]]   # Use the constructed link

      # Only proceed if both title and link are not NULL or NA
      if (!is.na(link) & !is.null(link) & !is.na(title) & !is.null(title)) {

        # Check if the keyword already exists in the list, if not, initialize it
        if (!is.null(keyword_link_groups[[keyword]])) {
          # Append the link to the existing list for that keyword
          keyword_link_groups[[keyword]] <- c(keyword_link_groups[[keyword]], link_info)
        } else {
          # Create a new entry for this keyword
          keyword_link_groups[[keyword]] <- list(link_info)
        }

        # Update the count for each keyword
        if (!is.null(keyword_count[[keyword]])) {
          keyword_count[[keyword]] <- keyword_count[[keyword]] + 1
        } else {
          keyword_count[[keyword]] <- 1
        }
      }
    }
  }

  # Now sort keywords by the number of entries and select the top 5
  sorted_keywords <- names(sort(unlist(keyword_count), decreasing = TRUE))[1:5]

  # Only retain the top 5 keywords in the final grouped list
  top_keyword_link_groups <- keyword_link_groups[sorted_keywords]

  # You can now use 'top_keyword_link_groups' for further processing, such as generating the Quarto file.

  # Construct the Quarto markdown for grouped links
  for (keyword in names(top_keyword_link_groups)) {
    # Start a new list group for each keyword
    markdown_content <- paste0(markdown_content, "### ", keyword, "\n\n")
    markdown_content <- paste0(markdown_content, "::: {list-group}\n")

    # Add all the links associated with this keyword (using titles for visible links)
    for (link_info in top_keyword_link_groups[[keyword]]) {
      title <- link_info[[1]]  # Use the title as the visible part of the link
      link <- link_info[[2]]   # Use the constructed link

      markdown_content <- paste0(markdown_content, "- [", title, "](", link, ")\n")
    }

    # End the list group
    markdown_content <- paste0(markdown_content, ":::\n\n")

  }

  # Write the markdown content to a file named topics.md
  writeLines(markdown_content, "topics.md")


}
