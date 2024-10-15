# Define a function to check pkg-config for a given package
check_pkg_config <- function(package) {
  pkg_config_path <- Sys.getenv("PKG_CONFIG_PATH")
  cat("PKG_CONFIG_PATH:", pkg_config_path, "\n")

  result <- system(paste("pkg-config --cflags --libs", package), intern = TRUE)
  if (length(result) > 0) {
    cat("pkg-config output for", package, ":\n", result, "\n")
  } else {
    cat("pkg-config could not find", package, "\n")
  }
}

# Check for libcurl
check_pkg_config("libcurl")
