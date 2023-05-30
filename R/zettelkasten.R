#' Title
#'
#' @param gallery_room_name
#'
#' @return
#' @export
#'
#' @examples
clean_gallery <- function() {
  logger::log_info('Removing old gallery ...')

  fs::dir_ls(
    'gallery',
    recurse = FALSE,
    type = 'dir',
    invert = TRUE,
    glob = '**/ejs'
  ) |>
    fs::dir_delete()

  logger::log_info('Removing old gallery complete.')
}

#' Title
#'
#' @return
#' @export
#'
#' @examples
mega_menu_template <- function(){
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
    }
    else {
      level_template <- '</ul>
        </li>
        <li class="gs_sub">
            <a role="menuitem" aria-haspopup="true" aria-expanded="false" href="/${href}">${text}</a>
            <ul role="menu">'
    }

    partial <- stringr::str_interp(level_template,
                          list(href = all_card_row["level_path"],
                               text = all_card_row["level"]))
  }
  else {
    sublevel_template <-
      '<li> <a role="menuitem" href="/${href}">${text}</a> </li>'
    partial <- stringr::str_interp(sublevel_template,
                          list(href = all_card_row["sublevel_path"],
                               text = all_card_row["sublevel"]))
  }

  return(partial)
}

gallery_1st_level_index_page_template <- "---
title: '${title}'
sidebar: false
toc: false
anchor-sections: false
listing:
  - id: ${slang}-listing
    template: ../ejs/tiles.ejs
    contents: listing-contents-${slang}.yml
---

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
create_1st_level_page <-  function(subset_data, key) {
  dir.create(key$level_path, recursive = TRUE)

  gallery_index_page <- stringr::str_interp(
    gallery_1st_level_index_page_template,
    list(title = key$level, slang= key$level_slang)
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
  dir.create(all_card_row["sublevel_path"], recursive = TRUE)

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
  thumbnail: ${thumbnail}"

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
          thumbnail = thumbnail
        )
      )
    ) |>
    dplyr::pull(listing_tiles) |>
    stringr::str_flatten(collapse="\n")

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
          thumbnail = thumbnail
        )
      )
    ) |>
    dplyr::pull(listing_tiles) |>
    stringr::str_flatten(collapse="\n")

  listing_path <- file.path(
    key$level_path[1],
    paste0("listing-contents-", key$level_slang[1], ".yml")
  )

  writeLines(listing_tiles, con = listing_path)
}

listing_2nd_level_template <- "- path: ../../../GESIS-Methods-Hub/minimal-example-md/index.md"

#' Title
#'
#' @param all_card_row
#'
#' @return
#' @export
#'
#' @examples
create_listing_2nd_level <- function(all_card_row) {
  dir.create(all_card_row["sublevel_path"], recursive = TRUE)

  listing_path <- file.path(all_card_row["sublevel_path"], stringr::str_interp("listing-contents-${slang}.yml", list(slang=all_card_row["sublevel_slang"])))

  writeLines(listing_2nd_level_template, con = listing_path)
}

#' Title
#'
#' @param all_card_filename
#'
#' @return
#' @export
#'
#' @examples
generate_card_files <- function(all_cards_filename = 'zettelkasten.csv') {
  clean_gallery()

  all_cards <- all_cards_filename |>
    fs::path_real() |>
    readr::read_csv()

  # Populate all_card with data to use downstream

  all_cards$level_slang <- all_cards$level |>
    stringr::str_to_lower() |>
    stringr::str_replace_all(" ", "-") |>
    stringr::str_replace_all("&", "and")

  all_cards$sublevel_slang <- all_cards$sublevel |>
    stringr::str_to_lower() |>
    stringr::str_replace_all(" ", "-") |>
    stringr::str_replace_all("&", "-and-")

  all_cards$level_path <- file.path("gallery",
                                   all_cards$level_slang)

  all_cards$sublevel_path <- file.path(all_cards$level_path,
                                      all_cards$sublevel_slang)


  mega_menu_partial <- all_cards |>
    dplyr::mutate(row_number =  dplyr::row_number()) |>
    apply(1, create_mega_menu) |>
    stringr::str_flatten()

  logger::log_info('Prepare ...')

  dir.create("_partials", recursive = TRUE)
  create_mega_menu_path <- "_partials/mega_menu.html"

  stringr::str_interp(
    mega_menu_template(),
    list(
      partial = mega_menu_partial
    )
  ) |>
    writeLines(con = create_mega_menu_path)


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
}
