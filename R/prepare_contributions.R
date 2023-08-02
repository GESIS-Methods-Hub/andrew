pre_process_github_link <- function(contribution_url) {
  regex_match <-
    stringr::str_match(contribution_url, "https://github.com/")

  if ((!is.na(regex_match[1])) && stringr::str_ends(contribution_url, ".git") == FALSE) {
    return(stringr::str_c(contribution_url, ".git"))
  }

  return(contribution_url)
}

pre_process_gitlab_link <- function(contribution_url) {
  regex_match <-
    stringr::str_match(contribution_url, "https://gitlab.com/")

  if ((!is.na(regex_match[1])) && stringr::str_ends(contribution_url, ".git") == FALSE) {
    return(stringr::str_c(contribution_url, ".git"))
  }

  return(contribution_url)
}

#' Enrich single contribution source
#'
#' @param contribution_row
#'
#' @return
#' @noRd
#'
#' @examples
pre_process_contributions_list <- function(contribution_row) {
  logger::log_debug("Pre-processing {contribution_row['link']} ...")
  contribution_url <- contribution_row["link"] |>
    pre_process_github_link() |>
    pre_process_gitlab_link()

  if (stringr::str_ends(contribution_url, ".git") == TRUE) {
    regex_match <-
      stringr::str_match(contribution_url, "https://(.*)/(.*)/(.*).git")

    return(paste0(regex_match[3], "/", regex_match[4]))
  }

  return("NA/NA")
}

#' Prepare contributions database
#'
#' @param all_contributions database
#'
#' @return database
#' @export
#'
#' @examples
prepare_contributions <- function(all_contributions) {
  all_contributions$slang <- all_contributions |>
    apply(1, pre_process_contributions_list)
  all_contributions <- all_contributions |>
    tidyr::separate_wider_delim(
      slang,
      delim = "/",
      names = c("user_name", "repository_name"),
      cols_remove = FALSE
    ) |>
    dplyr::mutate(
      slang = dplyr::na_if(slang, "NA/NA"),
      user_name = dplyr::na_if(user_name, "NA"),
      repository_name = dplyr::na_if(repository_name, "NA")
    )
  print(all_contributions)
  all_contributions$tmp_path <-
    stringr::str_c("_", all_contributions$slang)
  all_contributions$https <-
    stringr::str_replace(all_contributions$link, ".git$", "")
  all_contributions$filename_extension <-
    stringr::str_extract(all_contributions$filename, "(md|qmd|Rmd|ipynb|docx)$")

  return(all_contributions)
}
