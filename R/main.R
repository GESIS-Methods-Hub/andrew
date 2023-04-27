#' Main function to get third party resources
#'
#' @param content_contributions_filename Database with contributors
#'
#' @return
#' @export
#'
#' @examples
main <-
  function(content_contributions_filename = 'content-contributions.csv') {
    content_contributions_filename |>
      here::here() |>
      read_csv() |>
      prepare_contributions()

    return()
  }
