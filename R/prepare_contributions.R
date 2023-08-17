#' Prepare contributions database
#'
#' @param all_contributions database
#'
#' @return database
#' @export
#'
#' @examples
prepare_contributions <- function(all_contributions) {
  all_contributions$web_address <- ifelse(
    (
      (
        stringr::str_detect(all_contributions$web_address, "github.com") |
          stringr::str_detect(all_contributions$web_address, "gitlab.com")
      )
    ),
    ifelse(
      stringr::str_ends(all_contributions$web_address, ".git"),
      all_contributions$web_address,
      stringr::str_c(all_contributions$web_address, ".git")
    ),
    all_contributions$web_address
  )

  web_address_match_git <- stringr::str_match(all_contributions$web_address, "https?://(.*)/(.*)/(.*).git")
  all_contributions$domain <- web_address_match_git[, 2]
  all_contributions$user_name <- web_address_match_git[, 3]
  all_contributions$repository_name <- web_address_match_git[, 4]

  web_address_match <- stringr::str_match(all_contributions$web_address, "https?://(.*?)/(.*)")
  all_contributions$domain <- ifelse(
    is.na(all_contributions$domain),
    web_address_match[, 2],
    all_contributions$domain
  )

  all_contributions$slang <- ifelse(
    is.na(all_contributions$user_name),
    NA,
    stringr::str_c(all_contributions$user_name, "/", all_contributions$repository_name)
  )

  all_contributions$tmp_path <- ifelse(
    is.na(all_contributions$slang),
    stringr::str_c("_", all_contributions$domain),
    stringr::str_c("_", all_contributions$domain, "/", all_contributions$slang)
  )

  all_contributions$https <- ifelse(
    stringr::str_ends(all_contributions$web_address, ".git"),
    stringr::str_replace(all_contributions$web_address, ".git$", ""),
    NA
  )

  all_contributions$filename_extension <-
    stringr::str_extract(all_contributions$filename, "(md|qmd|Rmd|ipynb|docx)$")

  all_contributions$source_type <- ifelse(
    stringr::str_ends(all_contributions$web_address, ".git"),
    "Git",
    "HTTP"
  )

  return(all_contributions)
}
