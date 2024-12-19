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

  logger::log_debug("Downloading {http_url} ...")
  tryCatch(
    {
      download.file(http_url, http_file_path)
    },
    error = function(e) {
      logger::log_warn("Failed to download {http_url}: {e}")
    }
  )
  logger::log_debug("Download of {http_url} completed.")
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
  version <- contribution_row["version"]
  git_repo_path <- contribution_row["tmp_path"]
  # git_repo_path <- as.character(git_repo_path[[1]])

  git_url <- contribution_row["web_address"]

  logger::log_debug("{git_repo_path}")

  if (dir.exists(git_repo_path)) {
    logger::log_debug("{git_repo_path} already exists.")
    logger::log_debug("Skipping download of {git_url}.")
    logger::log_debug("Updating copy of {git_url}.")
    repo <- git_repo_path |>
      fs::path_real() |>
      git2r::repository()

    # repo |>
    #  git2r::reset(reset_type = "hard", path = ".")

    # only update if it is not in a detached state because a tag was previously selected.
    if (!git2r::is_detached(repo)) {
      repo |>
        git2r::pull()
    }
  } else {
    logger::log_debug("{git_repo_path} not found.")
    logger::log_debug("Downloading {git_url} ...")
    fs::dir_create(git_repo_path)
    repo <- git2r::clone(
      git_url,
      fs::path_real(git_repo_path)
    )
    # Check out the desired tag
    logger::log_debug("Download of {git_url} completed.")
  }
  if (!is.na(version)) {
    logger::log_debug("switching to version {version}")

    # Run 'git fetch --all' in the specified directory
    system(paste("cd", shQuote(git_repo_path), "&& git fetch --all"), intern = TRUE)

    git2r::checkout(repo, version, force=TRUE)
    logger::log_debug(paste("Checked out tag:", version))
  }
  else {
    logger::log_debug("Did not find any git tags as version in contribution.json, continuing with main branch")
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
  logger::log_debug("START downloading contributions")
  if (any(all_contributions$source_type == "Git")) {
    all_contributions |>
      dplyr::filter(source_type == "Git") |>
      apply(1, donwload_single_git_contribution)
  } else {
    logger::log_debug("No Git repository to process.")
  }

  if (any(all_contributions$source_type == "HTTP")) {
    all_contributions |>
      dplyr::filter(source_type == "HTTP") |>
      apply(1, donwload_single_http_contribution)
  } else {
    logger::log_debug("No Http source to process.")
  }

  logger::log_debug("END downloading contributions")

  return(all_contributions)
}
