#' Get last Git commit id
#'
#' @param contribution_row database row
#'
#' @return
#' @export
#'
#' @examples
get_last_commit_sha <- function(contribution_row) {
  repo <- git2r::repository(fs::path_real(contribution_row["tmp_path"]))
  last_commit <- git2r::revparse_single(repo, "HEAD")
  last_commit_sha <- git2r::sha(last_commit)

  return(last_commit_sha)
}

#' Add Git information to database
#'
#' @param all_contributions database
#'
#' @return
#' @export
#'
#' @examples
git_info_to_contributions <- function(all_contributions) {
  all_contributions$git_sha <- all_contributions |>
    apply(1, get_last_commit_sha)

  return(all_contributions)
}
