library(logger)

library(tidyverse)

#' Enrich single contribution source
#'
#' @param contribution_row
#'
#' @return
#' @noRd
#'
#' @examples
pre_process_contributions_list <- function(contribution_row) {
    regex_match <- str_match(contribution_row, 'https://github.com/(.*).git')
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
    all_contributions$slang <- apply(all_contributions, 1, pre_process_contributions_list)
    all_contributions <- all_contributions |>
        separate(slang, c("user_name", "repository_name"), sep='/', remove=FALSE)
    all_contributions$tmp_path <- str_c("_", all_contributions$slang)
    all_contributions$https <- str_replace(all_contributions$link, '.git$', '')

    return(all_contributions)
}
