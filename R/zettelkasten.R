# Install jsonlite package if not already installed
if (!require(jsonlite)) {
  install.packages("jsonlite")
}

# Install stringr package if not already installed
if (!require(stringr)) {
  install.packages("stringr")
}

# Load the stringr package
library(stringr)


# Load the jsonlite package
library(jsonlite)


#' Title
#'
#' @return
#' @export
#'
#' @examples
clean_gallery <- function() {
  logger::log_debug("Removing old gallery ...")

  fs::dir_ls(
    "gallery",
    recurse = FALSE,
    type = "dir",
    invert = TRUE,
    glob = "**/ejs"
  ) |>
    fs::dir_delete()

  logger::log_debug("Removing old gallery complete.")
}

#' Title
#'
#' @return
#' @export
#'
#' @examples
resolve_level <- function(all_card_row, all_level) {
  if (is.na(all_card_row$parent_collection)) {
    level <- all_card_row$title
  } else {
    level <- all_level |>
      dplyr::filter(id == all_card_row$parent_collection) |>
      dplyr::pull(title) |>
      dplyr::first()
  }

  return(level)
}

#' Title
#'
#' @return
#' @export
#'
#' @examples
resolve_sublevel <- function(all_card_row) {
  if (is.na(all_card_row$parent_collection)) {
    sublevel <- NA
  } else {
    sublevel <- all_card_row$title
  }

  return(sublevel)
}

#' Title
#'
#' @return
#' @export
#'
#' @examples
mega_menu_template <- function() {
  return('<button id="gs_mm_toggle_button-104618" class="gs_mm_toggle_button" aria-haspopup="true"
    aria-controls="gs_megamenu-104618" aria-label="Navigationsmenü"></button>
<nav class="gs_megamenu_nav" aria-labelledby="gs_mm_toggle_button-104618">
    <ul role="menu" id="gs_megamenu-104618" class="gs_megamenu">
        <li> <a role="menuitem" href="/">Home</a> </li>

${partial}
            </ul>
        </li>

    </ul>
</nav>')
}

#' Title
#'
#' @param all_card_row
#'
#' @return
#' @export
#'
#' @examples
create_mega_menu <- function(all_card_row) {
  if (is.na(all_card_row["sublevel"])) {
    # apply() cast row to single type
    if (as.numeric(all_card_row["row_number"]) == 1) {
      level_template <- '<li class="gs_sub">
            <a role="menuitem" aria-haspopup="true" aria-expanded="false" href="/${href}">${text}</a>
            <ul role="menu">'
    } else {
      level_template <- '</ul>
        </li>
        <li class="gs_sub">
            <a role="menuitem" aria-haspopup="true" aria-expanded="false" href="/${href}">${text}</a>
            <ul role="menu">'
    }

    partial <- stringr::str_interp(
      level_template,
      list(
        href = all_card_row["level_path"],
        text = all_card_row["level"]
      )
    )
  } else {
    sublevel_template <-
      '<li> <a role="menuitem" href="/${href}">${text}</a> </li>'
    partial <- stringr::str_interp(
      sublevel_template,
      list(
        href = all_card_row["sublevel_path"],
        text = all_card_row["sublevel"]
      )
    )
  }

  return(partial)
}

gallery_1st_level_index_page_template <- "---
title: '${title}'
sidebar: false
toc: false
anchor-sections: false
comments: false
listing:
  - id: ${slang}-listing
    template: ../ejs/tiles.ejs
    contents: listing-contents-${slang}.yml
---
${abstract}

:::{#${slang}-listing}
:::
"

#' Title
#'
#' @param subset_data
#' @param key
#'
#' @return
#' @export
#'
#' @examples
create_1st_level_page <- function(subset_data, key) {
  fs::dir_create(key$level_path)

  level <- key$level
  abstract <- subset_data[subset_data$title == level, "abstract"][[1]]

  gallery_index_page <- stringr::str_interp(
    gallery_1st_level_index_page_template,
    list(title = level,
         abstract = abstract,
         slang = key$level_slang)
  )

  gallery_index_path <- file.path(key$level_path, "index.md")

  writeLines(gallery_index_page, con = gallery_index_path)
}

# Create pages for 2nd level

gallery_2nd_level_index_page_template <- "---
title: '${title}'
sidebar: false
toc: false
anchor-sections: false
comments: false
listing:
  - id: ${slang}-listing
    template: ../../ejs/methods.ejs
    contents: listing-contents-${slang}.yml
---

${abstract}

:::{#${slang}-listing}
:::
"

#' Title
#'
#' @param all_card_row
#'
#' @return
#' @export
#'
#' @examples
create_2nd_level_page <- function(all_card_row) {
  fs::dir_create(all_card_row["sublevel_path"])

  gallery_index_page <- stringr::str_interp(
    gallery_2nd_level_index_page_template,
    list(
      title = all_card_row["sublevel"],
      abstract = all_card_row["abstract"],
      slang = all_card_row["sublevel_slang"]
    )
  )

  gallery_index_path <- file.path(all_card_row["sublevel_path"], "index.md")

  writeLines(gallery_index_page, con = gallery_index_path)
}

listing_tiles_template <- "- title: ${title}
  subtitle: ${subtitle}
  href: ${href}
  cover_image: ${cover_image}"

#' Title
#'
#' @param subset_data
#'
#' @return
#' @export
#'
#' @examples
create_listing_root_level <- function(subset_data) {
  listing_tiles <- subset_data |>
    dplyr::rowwise() |>
    dplyr::mutate(
      listing_tiles = stringr::str_interp(
        listing_tiles_template,
        list(
          title = level,
          subtitle = subtitle,
          href = level_path,
          cover_image = cover_image_local
        )
      )
    ) |>
    dplyr::pull(listing_tiles) |>
    stringr::str_flatten(collapse = "\n")

  listing_path <- file.path("listing-contents.yml")

  writeLines(listing_tiles, con = listing_path)
}

#' Title
#'
#' @param subset_data
#' @param key
#'
#' @return
#' @export
#'
#' @examples
create_listing_1st_level <- function(subset_data, key) {
  listing_tiles <- subset_data |>
    dplyr::rowwise() |>
    dplyr::mutate(
      listing_tiles = stringr::str_interp(
        listing_tiles_template,
        list(
          title = sublevel,
          subtitle = subtitle,
          href = sublevel_slang,
          cover_image = paste0("../../", cover_image_local)
        )
      )
    ) |>
    dplyr::pull(listing_tiles) |>
    stringr::str_flatten(collapse = "\n")

  listing_path <- file.path(
    key$level_path[1],
    paste0("listing-contents-", key$level_slang[1], ".yml")
  )

  writeLines(listing_tiles, con = listing_path)
}

#' Title
#'
#' @param all_card_row
#'
#' @return
#' @export
#'
#' @examples
create_listing_2nd_level <- function(all_card_row) {
  if (is.null(all_card_row$content_set)) {
    return()
  }

  fs::dir_create(all_card_row["sublevel_path"])

  listing_path <- file.path(
    all_card_row["sublevel_path"],
    stringr::str_interp(
      "listing-contents-${slang}.yml",
      list(
        slang = all_card_row["sublevel_slang"]
      )
    )
  )

  logger::log_debug("Retrieving content ...")
  content_df <- tibble::tibble(
    content = all_card_row$content_set
  ) |>
    tidyr::unnest_wider(content)
  logger::log_debug("Content successfully retrieved.")

  logger::log_debug("Generating path for content ...")

  content_df <- content_df |>
    prepare_contributions()

  content_df$final_path <- stringr::str_c(
    content_df$tmp_path,
    content_df$filename,
    sep = "/"
  )

  content_df$final_path <- content_df$final_path |>
    stringr::str_match("_(.+)\\.(.+)") |>
    (\(x) x[, 2])() |>
    stringr::str_c("/index.md")

  logger::log_debug("Path successfully generated.")

  content_df$final_path |>
    stringr::str_replace("^", "- path: ../../../") |>
    stringr::str_flatten("\n") |>
    writeLines(con = listing_path)
}

#' Title
#'
#' @param all_card_filename
#'
#' @return
#' @export
#'
#' @examples
generate_card_files <- function(all_cards_filename = "zettelkasten.json", is_minimal_example = FALSE) {
  if (is_minimal_example) {
    create_minimal_example_view()
    #create_full_view(all_cards_filename)
  } else {
    clean_gallery()
    create_full_view(all_cards_filename)
  }

}

create_minimal_example_view <- function(all_cards_filename = "content-contributions.json") {
  # Note: this is a terrible hack and should be condemned by a group of peers
  logger::log_debug("Creating Minimal_Example View...")
  logger::log_debug("Reading {all_cards_filename} into list ...")

  ######## Part 1: rewriting the index.md to only include one tool

  # Parse the JSON data
  data_list <- fromJSON(all_cards_filename)

  # Extract the first element
  first_element <- data_list[1, ]

  # Create a dataframe
  df <- as.data.frame(first_element)
  logger::log_debug("Creating view for {df$web_address} ")

   # Extract the web address
  web_address <- df$web_address

  ############ START copy the bib files
  tool_address <- gsub("^https://", "", web_address)

  # Define the source directory (appending "/index" to local_address)
  source_directory <- file.path(tool_address, "index")

  # Define the target directory
  target_directory <- "gallery/minimal_example/"

  # Ensure the target directory exists (create it if not)
  if (!dir.exists(target_directory)) {
    dir.create(target_directory, recursive = TRUE)
  }

  # Get a list of all .bib files in the source directory
  bib_files <- list.files(source_directory, pattern = "\\.bib$", full.names = TRUE)

  # Copy each .bib file to the target directory
  file.copy(bib_files, target_directory, overwrite = TRUE)

  # Replace "https://" with "../../"
  local_address <- gsub("^https://", "../../", web_address)

  # Remove ".git" at the end of the address
  local_address <- gsub("\\.git$", "", local_address)

  # Get the file names (without the full path) to store in YAML
  bib_file_names <- basename(bib_files)

  ############ END copy the bib files

  # Construct the content of the index.md file
  index_md_content <- paste0(
    "---\n",
    "title: 'Minimal Example'\n",
    "sidebar: false\n",
    "toc: false\n",
    "bibliography:\n",
    paste0("  - ", bib_file_names, collapse = "\n"),
    "\nanchor-sections: false\n",
    "comments: false\n",
    "---\n\n",
    "{{< include ", local_address, "/index/index.md >}}\n"
  )



  # Define the output file path
  output_file_path <- "gallery/minimal_example/index.md"

  # Ensure the output directory exists
  dir.create(dirname(output_file_path), recursive = TRUE, showWarnings = FALSE)

  # Write the content to the file
  writeLines(index_md_content, output_file_path)

  # Print confirmation message
  logger::log_info("[zettelkasten.R] index.md file has been written to ", output_file_path, "\n")


  ######## Part 2: rewriting the method-title-block with the correct path to the new tools
  # 2a) (re-)write method-title-block to change the download tool as links to the correct path
  # 2b) TODO the other partials probably need to be changed, too

  # Read the HTML file
  html_file_path <- "_partials/_method-title-block.html"
  html_content <- readLines(html_file_path, warn = FALSE)

  # Define the placeholder and replacement content
  placeholder <- "<span id=\"replaced_by_zettelkastenR\"></span>"
  replacement <- paste0('<ul class="dropdown-menu">',
                        '<li><a class="dropdown-item" href="', local_address, '/index/index.ipynb"> <i class="bi bi-file-earmark-richtext"></i> Jupyter Notebook</a></li>',
                        '<li><a class="dropdown-item" href="', local_address, '/index/index.qmd"> <i class="bi bi-file-earmark-text"></i> Quarto</a></li>',
                        '<li><a class="dropdown-item" href="', local_address, '/index/index.pdf"> <i class="bi bi-file-earmark-pdf"></i> PDF</a></li>',
                        '</ul>')

  # Replace the placeholder in the HTML content
  modified_html_content <- str_replace_all(html_content, fixed(placeholder), replacement)

  # Write the modified HTML back to a file
  output_file_path <- "_partials/method-title-block.html"
  writeLines(modified_html_content, output_file_path)

  logger::log_info("[Zettelkasten.R] The _method_title_block.html modified and saved to:", output_file_path)




}


create_full_view <- function(all_cards_filename) {
  logger::log_debug("Reading {all_cards_filename} into list ...")
  all_cards_list <- all_cards_filename |>
    fs::path_real() |>
    jsonlite::read_json()
  logger::log_debug("List successfully created.")

  logger::log_debug("Converting list into data frame ...")
  all_cards <- tibble::tibble(
    collections = all_cards_list
  ) |>
    tidyr::unnest_wider(collections)
  logger::log_debug("Data frame successfully created.")

  logger::log_debug("Expanding data frame ...")

  all_cards$level <- ""
  all_cards$sublevel <- ""

  all_level <- all_cards |>
    dplyr::filter(is.na(parent_collection)) |>
    dplyr::select(id, title)

  all_cards$level <- all_cards |>
    apply(1, resolve_level, all_level)
  all_cards$sublevel <- all_cards |>
    apply(1, resolve_sublevel)

  all_cards$level_slang <- all_cards$level |>
    stringr::str_to_lower() |>
    stringr::str_replace_all(" ", "-") |>
    stringr::str_replace_all("&", "and")

  all_cards$sublevel_slang <- all_cards$sublevel |>
    stringr::str_to_lower() |>
    stringr::str_replace_all(" ", "-") |>
    stringr::str_replace_all("&", "-and-")

  all_cards$level_path <- file.path(
    "gallery",
    all_cards$level_slang
  )

  all_cards$sublevel_path <- file.path(
    all_cards$level_path,
    all_cards$sublevel_slang
  )

  logger::log_debug("Data frame successfully expanded.")

  logger::log_debug("Downloading all cover image ...")

  all_cards$cover_image_local <- all_cards |>
    dplyr::pull(cover_image) |>
    lapply(download_cover_image)

  logger::log_debug("Cover image all successfully downloaded.")

  logger::log_debug("Preparing mega menu ...")

  mega_menu_partial <- all_cards |>
    dplyr::arrange(level, !is.na(sublevel), sublevel) |>
    dplyr::mutate(row_number = dplyr::row_number()) |>
    apply(1, create_mega_menu) |>
    stringr::str_flatten()

  logger::log_debug("Mega menu successfully prepared.")

  logger::log_debug("Writting mega menu ...")

  fs::dir_create("_partials")
  create_mega_menu_path <- "_partials/mega_menu.html"

  stringr::str_interp(
    mega_menu_template(),
    list(
      partial = mega_menu_partial
    )
  ) |>
    writeLines(con = create_mega_menu_path)

  logger::log_debug("Mega menu successfully written.")

  logger::log_debug("Creating navigation pages ...")

  all_cards |>
    dplyr::group_by(level, level_slang, level_path) |>
    dplyr::group_walk(create_1st_level_page)

  all_cards |>
    dplyr::filter(!is.na(sublevel)) |>
    apply(1, create_2nd_level_page)

  all_cards |>
    dplyr::filter(is.na(sublevel)) |>
    create_listing_root_level()

  all_cards |>
    dplyr::filter(!is.na(sublevel)) |>
    dplyr::group_by(level_path, level_slang) |>
    dplyr::group_walk(create_listing_1st_level)

  all_cards |>
    dplyr::filter(!is.na(sublevel)) |>
    apply(1, create_listing_2nd_level)

  logger::log_debug("Navigation pages created.")
}
