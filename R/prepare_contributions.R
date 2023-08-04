#' Prepare contributions database
#'
#' @param all_contributions database
#'
#' @return database
#' @export
#'
#' @examples
prepare_contributions <- function(all_contributions) {
  all_contributions$link <- ifelse(
    (
      (
        stringr::str_detect(all_contributions$link, "github.com") |
        stringr::str_detect(all_contributions$link, "gitlab.com")
      )
    ),
    ifelse(
        stringr::str_ends(all_contributions$link, '.git'),
        all_contributions$link,
        stringr::str_c(all_contributions$link, '.git')
    ),
    all_contributions$link
  )

  link_match_git <- stringr::str_match(all_contributions$link, "https://(.*)/(.*)/(.*).git")
  all_contributions$domain <- link_match_git[, 2]
  all_contributions$user_name <- link_match_git[, 3]
  all_contributions$repository_name <- link_match_git[, 4]

  link_match <- stringr::str_match(all_contributions$link, "https://(.*?)/(.*)")
  all_contributions$domain <- ifelse(
    is.na(all_contributions$domain),
    link_match[, 2],
    all_contributions$domain
  )

  all_contributions$slang <- ifelse(
    is.na(all_contributions$user_name),
    NA,
    stringr::str_c(all_contributions$user_name, '/', all_contributions$repository_name)
  )

  all_contributions$tmp_path <- ifelse(
    is.na(all_contributions$slang),
    stringr::str_c("_", all_contributions$domain),
    stringr::str_c("_", all_contributions$domain, "/", all_contributions$slang)
  )

  all_contributions$https <- ifelse(
    stringr::str_ends(all_contributions$link, '.git'),
    stringr::str_replace(all_contributions$link, ".git$", ""),
    NA
  )

  all_contributions$filename_extension <-
    stringr::str_extract(all_contributions$filename, "(md|qmd|Rmd|ipynb|docx)$")

  return(all_contributions)
}
