#' Title
#'
#' @return
#' @export
#'
#' @examples
download_cover_image <- function(url) {
  if (stringr::str_starts(url, "https?:", negate = TRUE)) {
    logger::log_debug("{url} is a local file. Skipping download.")
    return(url)
  }
  
  dir_path <- fs::path("static", "cover_image")
  fs::dir_create(dir_path)

  filename <- fs::path_file(url)
  file_path <- fs::path(dir_path, filename)
  file_path_abs <- file_path |>
    fs::path_abs()

  logger::log_debug("Downloading {url} to {file_path_abs} ...")
  download.file(url, file_path, quiet = TRUE)
  logger::log_debug("File successfully downloaded.")

  return(file_path)
}
