#' Enrich single contribution source
#'
#' @param contribution_row
#'
#' @return
#' @noRd
#'
#' @examples
pre_process_contributions_list <- function(contribution_row) {
  regex_match <-
    stringr::str_match(contribution_row["link"], 'https://github.com/(.*).git')
  user_and_project <- regex_match[2]

  return(user_and_project)
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
      delim = '/',
      names = c("user_name", "repository_name"),
      cols_remove = FALSE
    )
  all_contributions$tmp_path <-
    stringr::str_c("_", all_contributions$slang)
  all_contributions$https <-
    stringr::str_replace(all_contributions$link, '.git$', '')
  all_contributions$filename_extension <-
    stringr::str_extract(all_contributions$filename, '(md|qmd|ipynb)$')

  return(all_contributions)
}
