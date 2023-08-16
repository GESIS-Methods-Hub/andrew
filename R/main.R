#' Main function to get third party resources
#'
#' @param content_contributions_filename Database with contributors
#'
#' @return
#' @export
#'
#' @examples
main <-
  function(content_contributions_filename = "content-contributions.json",
           all_cards_filename = "zettelkasten.csv",
           source_dir = ".") {
    original_wd <- fs::path_real(".")

    source_dir |>
      fs::path_real() |>
      setwd()

    contribution_report <- NA

    tryCatch(
      {
        contribution_report <- content_contributions_filename |>
          fs::path_real() |>
          jsonlite::read_json(simplifyVector = TRUE) |>
          tibble::as_tibble() |>
          prepare_contributions() |>
          download_contributions() |>
          git_info_to_contributions() |>
          create_containers() |>
          render_contributions() |>
          render_report()

        generate_card_files(all_cards_filename)
      },
      error = function(e) {
        logger::log_info("{e}")
      }
    )

    setwd(original_wd)

    return(contribution_report)
  }
