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
           all_cards_filename = "zettelkasten.json",
           source_dir = ".") {
    original_wd <- fs::path_real(".")

    source_dir |>
      fs::path_real() |>
      setwd()

    contribution_report <- NA

    tryCatch(
      {
        content_contributions_list <- content_contributions_filename |>
          fs::path_real() |>
          jsonlite::read_json()

        content_contributions_df <- tibble::tibble(
          contributions = content_contributions_list
        ) |>
          tidyr::unnest_wider(contributions)

        contribution_report <- content_contributions_df
        logger::log_info("Preparing contributions")
        contribution_report <- prepare_contributions(contribution_report)
        logger::log_info("Downloading contributions")
        contribution_report <- download_contributions(contribution_report)
        logger::log_info("Adding git info to contributions")
        contribution_report <- git_info_to_contributions(contribution_report)
        logger::log_info("Creating containers")
        contribution_report <- create_containers(contribution_report)
        logger::log_info("Rendering contributions")
        contribution_report <- render_contributions(contribution_report)
        logger::log_info("Rendering report")
        contribution_report <- render_report(contribution_report)
        generate_card_files(all_cards_filename)
        logger::log_info("generated card files")
      },
      error = function(e) {
        logger::log_info("{e}")
      }
    )

    setwd(original_wd)

    return(contribution_report)
  }
