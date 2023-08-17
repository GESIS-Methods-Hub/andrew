#' Download single non-Git contribution
#'
#' @param contribution_row database row
#'
#' @return
#' @export
#'
#' @examples
donwload_single_http_contribution <- function(contribution_row) {
  http_dir_path <- contribution_row["tmp_path"]
  http_file_path <- fs::path(http_dir_path, contribution_row["filename"])
  http_url <- contribution_row["web_address"]

  fs::dir_create(http_dir_path)

  logger::log_info("Downloading {http_url} ...")
  tryCatch(
    {
      download.file(http_url, http_file_path)
    },
    error = function(e) {
      logger::log_warn("Failed to download {http_url}: {e}")
    }
  )
  logger::log_info("Download of {http_url} completed.")
}

#' Download single Git contribution
#'
#' @param contribution_row database row
#'
#' @return
#' @export
#'
#' @examples
donwload_single_git_contribution <- function(contribution_row) {
  git_repo_path <- contribution_row["tmp_path"]
  git_url <- contribution_row["web_address"]

  if (dir.exists(git_repo_path)) {
    logger::log_info("{git_repo_path} already exists.")
    logger::log_info("Skipping download of {git_url}.")
    logger::log_info("Updating copy of {git_url}.")
    repo <- git_repo_path |>
      fs::path_real() |>
      git2r::repository()

    repo |>
      git2r::reset(reset_type = "hard", path = ".")

    repo |>
      git2r::pull()
  } else {
    logger::log_info("{git_repo_path} not found.")
    logger::log_info("Downloading {git_url} ...")
    fs::dir_create(git_repo_path)
    git2r::clone(
      git_url,
      fs::path_real(git_repo_path)
    )
    logger::log_info("Download of {git_url} completed.")
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
  if (any(all_contributions$source_type == "Git")) {
    all_contributions |>
      dplyr::filter(source_type == "Git") |>
      apply(1, donwload_single_git_contribution)
  } else {
    logger::log_info("No Git repository to process.")
  }

  if (any(all_contributions$source_type == "HTTP")) {
    all_contributions |>
      dplyr::filter(source_type == "HTTP") |>
      apply(1, donwload_single_http_contribution)
  } else {
    logger::log_info("No Http source to process.")
  }

  return(all_contributions)
}
