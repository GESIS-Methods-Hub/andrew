#' Title
#'
#' @param all_contributions
#'
#' @return
#' @export
#'
#' @examples
render_report <- function(all_contributions, report_filename="_report-table.md") {
  all_contributions |>
    dplyr::select(link, status) |>
    knitr::kable("simple") |>
    writeLines(report_filename)

  return(all_contributions)
}
