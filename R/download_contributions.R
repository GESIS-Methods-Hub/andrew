#' Download single contribution
#'
#' @param contribution_row database row
#'
#' @return
#' @export
#'
#' @examples
donwload_single_contribution <- function(contribution_row) {
  if (dir.exists(contribution_row["tmp_path"])) {
    logger::log_info('{contribution_row["tmp_path"]} already exists.')
    logger::log_info('Skipping download of {contribution_row["link"]}.')
    logger::log_info('Updating copy of {contribution_row["link"]}.')
    repo <- contribution_row["tmp_path"] |>
      fs::path_real() |>
      git2r::repository()

    repo |>
      git2r::reset(reset_type = 'hard')

    repo |>
      git2r::pull()
  } else {
    logger::log_info('{contribution_row["tmp_path"]} not found.')
    logger::log_info('Downloading {contribution_row["link"]} ...')
    git2r::clone(contribution_row["link"],
                 fs::path_real(contribution_row["tmp_path"]))
    logger::log_info('Download of {contribution_row["link"]} completed.')
  }
}

#' Download all contributions from database
#'
#' @param all_contributions database
#'
#' @return
#' @export
#'
#' @examples
download_contributions <- function(all_contributions) {
  all_contributions |>
    apply(1, donwload_single_contribution)

  return(all_contributions)
}
