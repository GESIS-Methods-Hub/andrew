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
    setwd(contribution_row["tmp_path"])
    system(paste("git", "clean", "--force", "-x"))
    system(paste("git", "pull"))
    setwd("../..")
  } else {
    logger::log_info('{contribution_row["tmp_path"]} not found.')
    logger::log_info('Downloading {contribution_row["link"]} ...')
    system(paste("git clone", contribution_row["link"], contribution_row["tmp_path"]))
    logger::log_info('Download of {contribution_row["link"]} completed.')
  }
}

#' Donwload all contributions from database
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
