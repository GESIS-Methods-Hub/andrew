# Script to update tree naviagtion

library(logger)

library(stringr)

library(dplyr)

zettelkasten <- read.csv('zettelkasten.csv', header=TRUE)

# Populate zettelkasten with data to use downstream

zettelkasten$level_slang <- zettelkasten$level |>
    str_to_lower() |>
    str_replace_all(" ", "-") |>
    str_replace_all("&", "-and-")

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

# Create updated pages

gallery_index_page_template <- "---
title: '${title}'
sidebar: false
toc: false
listing:
  - id: overview
    template: ../ejs/overview.ejs
    contents: listing-contents.yml
css: 
 - ../gallery.css
---

:::{.column-screen}

${abstract}

:::{#overview}
:::

:::
"

create_page <- function(zettelkasten_row) {
    dir.create(zettelkasten_row["sublevel_path"], recursive = TRUE)

    gallery_index_page <- str_interp(
        gallery_index_page_template,
        list(title = zettelkasten_row["sublevel"], abstract = zettelkasten_row["abstract"])
    )

    gallery_index_path <- file.path(zettelkasten_row["sublevel_path"], "index.md")

    writeLines(gallery_index_page, con = gallery_index_path)
}

zettelkasten |>
    apply(1, create_page) |>
    invisible()

# Create listing

listing_template <- "- category: Gallery
  description: |
    Explore the Gallery of reusable code
  tiles:
${tiles}"

listing_tiles_template <- "    - title: ${title}
      subtitle: ${subtitle}
      href: ${href}
      thumbnail: ${thumbnail}"

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

    listing <- str_interp(
        listing_template,
        list(
            tiles = listing_tiles
        )
    )

    listing_path <- file.path(key$level_path[1], "listing-contents.yml")

    writeLines(listing, con = listing_path)
}

zettelkasten |>
    group_by(level_path) |>
    group_walk(create_listing_1st_level) |>
    invisible()
