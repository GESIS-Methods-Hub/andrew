#' Main function to get third party resources
#'
#' @param content_contributions_filename Database with contributors
#'
#' @return
#' @export
#'
#' @examples
main <-
  function(content_contributions_filename = 'content-contributions.csv',
           all_cards_filename = 'zettelkasten.csv',
           source_dir = '.') {
    original_wd <- fs::path_real('.')

    source_dir |>
      fs::path_real() |>
      setwd()

    tryCatch({
      contribution_report <- content_contributions_filename |>
        fs::path_real() |>
        readr::read_csv() |>
        prepare_contributions() |>
        download_contributions() |>
        git_info_to_contributions() |>
        create_containers() |>
        render_contributions()
    }, error = function(e) {
      logger::log_info('{e}')
    })

    generate_card_files(all_cards_filename)

    setwd(original_wd)

    return(contribution_report)
  }