# Script to update tree naviagtion

library(logger)

library(tidyverse)

zettelkasten <- read_csv('zettelkasten.csv')

# Populate zettelkasten with data to use downstream

zettelkasten$level_slang <- zettelkasten$level |>
    str_to_lower() |>
    str_replace_all(" ", "-") |>
    str_replace_all("&", "and")

zettelkasten$sublevel_slang <- zettelkasten$sublevel |>
    str_to_lower() |>
    str_replace_all(" ", "-") |>
    str_replace_all("&", "-and-")

zettelkasten$level_path <- file.path(
    "gallery",
    zettelkasten$level_slang
)

zettelkasten$sublevel_path <- file.path(
    zettelkasten$level_path,
    zettelkasten$sublevel_slang
)

# Remove old pages

old_gallery <- list.files('gallery')

clean_gallery <- function(gallery_room_name) {
    if (!(gallery_room_name %in% c('ejs', 'gallery.css'))) {
        unlink(
            file.path('gallery', gallery_room_name),
            recursive = TRUE,
            force = TRUE
        )
    }
}

old_gallery |>
    lapply(clean_gallery) |>
    invisible()

# Create pages for 1st level

gallery_1st_level_index_page_template <- "---
title: '${title}'
sidebar: false
toc: false
listing:
  - id: ${slang}-listing
    template: ../ejs/tiles.ejs
    contents: listing-contents-${slang}.yml
css: 
 - ../gallery.css
---

:::{.column-screen}

:::{#${slang}-listing}
:::

:::
"

create_1st_level_page <-  function(subset_data, key) {
    dir.create(key$level_path, recursive = TRUE)

    gallery_index_page <- str_interp(
        gallery_1st_level_index_page_template,
        list(title = key$level, slang= key$level_slang)
    )

    gallery_index_path <- file.path(key$level_path, "index.md")

    writeLines(gallery_index_page, con = gallery_index_path)
}

zettelkasten |>
    group_by(level, level_slang, level_path) |>
    group_walk(create_1st_level_page) |>
    invisible()

# Create pages for 2nd level

gallery_2nd_level_index_page_template <- "---
title: '${title}'
sidebar: false
toc: false
listing:
  - id: ${slang}-listing
    type: grid
    contents: listing-contents-${slang}.yml
css: 
 - ../../gallery.css
---

:::{.column-screen}

${abstract}

:::{#${slang}-listing}
:::

:::
"

create_2nd_level_page <- function(zettelkasten_row) {
    dir.create(zettelkasten_row["sublevel_path"], recursive = TRUE)

    gallery_index_page <- str_interp(
        gallery_2nd_level_index_page_template,
        list(
            title = zettelkasten_row["sublevel"],
            abstract = zettelkasten_row["abstract"],
            slang = zettelkasten_row["sublevel_slang"]
        )
    )

    gallery_index_path <- file.path(zettelkasten_row["sublevel_path"], "index.md")

    writeLines(gallery_index_page, con = gallery_index_path)
}

zettelkasten |>
    filter(!is.na(sublevel)) |>
    apply(1, create_2nd_level_page) |>
    invisible()

# Create listing

listing_tiles_template <- "- title: ${title}
  subtitle: ${subtitle}
  href: ${href}
  thumbnail: ${thumbnail}"

# Create listing for root level

create_listing_root_level <- function(subset_data) {
    listing_tiles <- subset_data |>
        rowwise() |>
        mutate(
            listing_tiles = str_interp(
                listing_tiles_template,
                list(
                    title = level,
                    subtitle = subtitle,
                    href = level_path,
                    thumbnail = thumbnail
                )
            )
        ) |>
        pull(listing_tiles) |>
        str_flatten(collapse="\n")

    listing_path <- file.path("listing-contents.yml")

    writeLines(listing_tiles, con = listing_path)
}

zettelkasten |>
    filter(is.na(sublevel)) |>
    create_listing_root_level() |>
    invisible()

# Create listing for 1st level

create_listing_1st_level <- function(subset_data, key) {
    listing_tiles <- subset_data |>
        rowwise() |>
        mutate(
            listing_tiles = str_interp(
                listing_tiles_template,
                list(
                    title = sublevel,
                    subtitle = subtitle,
                    href = sublevel_slang,
                    thumbnail = thumbnail
                )
            )
        ) |>
        pull(listing_tiles) |>
        str_flatten(collapse="\n")

    listing_path <- file.path(
        key$level_path[1],
        paste0("listing-contents-", key$level_slang[1], ".yml")
    )

    writeLines(listing_tiles, con = listing_path)
}

zettelkasten |>
    filter(!is.na(sublevel)) |>
    group_by(level_path, level_slang) |>
    group_walk(create_listing_1st_level) |>
    invisible()

# Create listing for 2nd level

listing_2nd_level_template <- "- path: ../../../GESIS-Methods-Hub/minimal-example-md/index.md"

create_listing_2nd_level <- function(zettelkasten_row) {
    dir.create(zettelkasten_row["sublevel_path"], recursive = TRUE)

    listing_path <- file.path(zettelkasten_row["sublevel_path"], str_interp("listing-contents-${slang}.yml", list(slang=zettelkasten_row["sublevel_slang"])))

    writeLines(listing_2nd_level_template, con = listing_path)
}

zettelkasten |>
    filter(!is.na(sublevel)) |>
    apply(1, create_listing_2nd_level) |>
    invisible()
