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

}
