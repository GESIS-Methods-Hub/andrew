#' Download single contribution
#'
#' @param contribution_row database row
#'
#' @return
#' @export
#'
#' @examples
donwload_single_contribution <- function(contribution_row) {
  git_repo_path <- contribution_row["tmp_path"]
  git_url <- contribution_row["link"]

  if (dir.exists(git_repo_path)) {
    logger::log_info('{git_repo_path} already exists.')
    logger::log_info('Skipping download of {git_url}.')
    logger::log_info('Updating copy of {git_url}.')
    repo <- git_repo_path |>
      fs::path_real() |>
      git2r::repository()

    repo |>
      git2r::reset(reset_type = 'hard', path='.')

    repo |>
      git2r::pull()
  } else {
    logger::log_info('{git_repo_path} not found.')
    logger::log_info('Downloading {git_url} ...')
    git2r::clone(git_url,
                 fs::path_real(git_repo_path))
    logger::log_info('Download of {git_url} completed.')
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
