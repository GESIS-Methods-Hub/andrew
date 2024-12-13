library(ymlthis)
library(yaml)
library(rmarkdown)


#' Render single contribution
#'
#' @param contribution_row
#'
#' @return
#' @export
#'
#' @examples
create_output_directory <- function(output_location) {
  investigate_file_or_directory(output_location)
  if (!dir.create(output_location, recursive = TRUE, showWarnings = FALSE)) {
    # Check if the directory creation failed
    if (!file.exists(output_location)) {
      stop(paste("Failed to create the directory:", output_location))
    }
  } else {
    # Directory was created successfully
    logger::log_debug(paste("Directory created successfully at:", output_location))

    # Set permissions to 777
    tryCatch({
      Sys.chmod(output_location, mode = "0777", use_umask = FALSE)
      logger::log_debug(paste("Permissions set to 777 for directory:", output_location))
    }, error = function(e) {
      logger::log_error(paste("Failed to set permissions for directory:", output_location, "Error:", e$message))
    })
  }
}

render_single_contribution <- function(contribution_row) {
  logger::log_debug("Rendering {contribution_row['filename']} from {contribution_row['web_address']}")

  host_user_id <- system("id -u", intern = TRUE)
  host_group_id <- system("id -g", intern = TRUE)
  logger::log_debug("Running with user ID {host_user_id} and group id {host_group_id}.")

  RENDER_MATRIX <- list(
    "md" = c(
      "md2md.sh",
      "md2qmd.sh",
      "md2ipynb.sh"
    ),
    "qmd" = c(
      "qmd2md.sh",
      "qmd2qmd.sh",
      "qmd2ipynb.sh"
    ),
    "Rmd" = c(
      "Rmd2md.sh",
      "Rmd2qmd.sh",
      "Rmd2ipynb.sh"
    ),
    "ipynb" = c(
      "ipynb2md.sh",
      "ipynb2qmd.sh",
      "ipynb2ipynb.sh"
    ),
    "docx" = c(
      "docx2md.sh"
    )
  )

  if (is.na(contribution_row["docker_image"])) {
    logger::log_warn("Docker image is NA! Using registry.gitlab.com/quarto-forge/docker/quarto.")
    docker_image <- "registry.gitlab.com/quarto-forge/docker/quarto"
    home_dir_at_docker <- "/tmp"
    render_at_dir <- fs::path(contribution_row["domain"])
    mount_input_file <- stringr::str_interp(
      "--mount type=bind,source=${input_file_path},target=${home_dir_at_docker}/${filename}",
      list(
        input_file_path = fs::path_real(fs::path(contribution_row["tmp_path"], contribution_row["filename"])),
        home_dir_at_docker = home_dir_at_docker,
        filename = contribution_row["filename"]
      )
    )
  } else {
    docker_image <- contribution_row["docker_image"]
    home_dir_at_docker <- "/home/andrew"
    render_at_dir <- fs::path(contribution_row["domain"], contribution_row["slang"])
    mount_input_file <- ""
  }

  file2render <- contribution_row["filename"]
  file2render_extension <- contribution_row["filename_extension"]
  github_https <- contribution_row["https"]
  github_user_name <- contribution_row["user_name"]
  github_repository_name <- contribution_row["repository_name"]

  fs::dir_create(render_at_dir)

  docker_scripts_location <-
    system.file("docker-scripts", package = "andrew", mustWork = TRUE)
  pandoc_filters_location <-
    system.file("pandoc-filters", package = "andrew", mustWork = TRUE)

  output_location <- render_at_dir |>
    fs::path_real()
  output_location_in_container <- "/tmp/andrew"

  logger::log_debug("Location of docker_scripts directory: {docker_scripts_location}")
  logger::log_debug("Location of pandoc_filters directory: {pandoc_filters_location}")
  logger::log_debug("Location of output directory: {output_location}")
  logger::log_debug("Location of output directory inside the container: {output_location_in_container}")

  create_output_directory(output_location)


  sum_docker_return_value <- 0
  for (script in get(file2render_extension, RENDER_MATRIX)) {
    logger::log_debug("Rendering using {script} ...")

    docker_call_template <- 'docker run \\
    --user=${host_user_id}:${host_group_id} \\
    ${mount_input_file} \\
    --mount type=bind,source=${docker_scripts_location},target=${home_dir_at_docker}/_docker-scripts \\
    --env docker_script_root=${home_dir_at_docker}/_docker-scripts \\
    --mount type=bind,source=${pandoc_filters_location},target=${home_dir_at_docker}/_pandoc-filters \\
    --mount type=bind,source=${output_location},target=${output_location_in_container} \\
    --env github_https=${github_https} \\
    --env github_user_name=${github_user_name} \\
    --env github_repository_name=${github_repository_name} \\
    --env file2render=${file2render} \\
    --env docker_image=${docker_image} \\
    --env output_location=${output_location_in_container} \\
    ${docker_image} \\
    /bin/bash -c "${home_dir_at_docker}/_docker-scripts/${script}"'

    docker_call <- stringr::str_interp(
      docker_call_template,
      list(
        host_user_id = host_user_id,
        host_group_id = host_group_id,
        mount_input_file = mount_input_file,
        home_dir_at_docker = home_dir_at_docker,
        docker_scripts_location = docker_scripts_location,
        pandoc_filters_location = pandoc_filters_location,
        output_location = output_location,
        output_location_in_container = output_location_in_container,
        file2render = file2render,
        github_https = github_https,
        github_user_name = github_user_name,
        github_repository_name = github_repository_name,
        docker_image = docker_image,
        script = script
      )
    )
    logger::log_info(docker_call)

    docker_return_value <- system(docker_call)

    logger::log_debug("Rendering markdown complete. Docker returned {docker_return_value}.")
    markdown_files <- list.files(output_location, recursive = TRUE)
    logger::log_debug("Output dir {output_location} contains the files {markdown_files}" )

    sum_docker_return_value <- sum_docker_return_value + docker_return_value
  }

  # Extract filename without extension
  file2render_basename <- tools::file_path_sans_ext(file2render)
  # add the citation.cff data if available
  index_md <- file.path(output_location, file2render_basename, "index.md")
  citation_cff <- file.path(output_location, file2render_basename, "CITATION.cff")
  update_citation_metadata(citation_file = citation_cff, output_file = index_md)

  if (sum_docker_return_value == 0) {
    build_status <- "Built"

    logger::log_debug("Rendering PDF ...")

    docker_pdf_call_template <- 'docker run \\
      --user=${host_user_id}:${host_user_id} \\
      --mount type=bind,source=${docker_scripts_location},target=/home/mambauser/_docker-scripts \\
      --mount type=bind,source=${output_location},target=/home/mambauser/andrew \\
      --env file2render=${file2render} \\
      registry.gitlab.com/quarto-forge/docker/quarto_all \\
      /bin/bash -c "/home/mambauser/_docker-scripts/md2pdf.sh"'

    docker_pdf_call <- stringr::str_interp(
      docker_pdf_call_template,
      list(
        host_user_id = host_user_id,
        docker_scripts_location = docker_scripts_location,
        output_location = output_location,
        output_location_in_container = output_location_in_container,
        file2render = file2render
      )
    )

    docker_return_value <- system(docker_pdf_call)

    logger::log_debug("Rendering PDF completed.")
  } else {
    build_status <- "Unavailable"
    logger::log_debug("Skipping PDF rendering.")
  }

  return(build_status)
}


#' Render all contributions from database
#'
#' @param all_contributions
#'
#' @return
#' @export
#'
#' @examples
render_contributions <- function(all_contributions) {
  all_contributions$status <- all_contributions |>
    apply(1, render_single_contribution)

  return(all_contributions)
}

#' Use CITATION.cff to fill the metadata for the tools
#' This uses the created index.md file
#'
update_citation_metadata <- function(citation_file, output_file) {

  investigate_file_or_directory(output_file)

  # Check if the CITATION.cff file exists
  if (!file.exists(citation_file)) {
    message("CITATION.cff file not found. No changes made to the output file.")
    return()
  }

  # Parse the CITATION.cff file
  citation_yaml <- yaml::read_yaml(citation_file)

  # Extract the URL from CITATION.cff or use a default value
  url_field <- NULL
  if (!is.null(citation_yaml$identifiers)) {
    url_field <- citation_yaml$identifiers[[1]]$value
  }
  url <- ifelse(!is.null(url_field), url_field, "https://kodaqs-toolbox.gesis.org/")

  # Generate the desired citation metadata
  citation_metadata <- list(
    citation = list(
      type = "document",
      title = citation_yaml$title,
      author = lapply(citation_yaml$authors, function(author) {
        if (!is.null(author$name)) {
          # Handle the case where the author has a single "name" field
          list(name = author$name)
        } else if (!is.null(author$`given-names`) && !is.null(author$`family-names`)) {
          # Handle the case where the author has separate "given-names" and "family-names"
          list(name = paste(author$`given-names`, author$`family-names`))
        }
      }),
      issued = if (!is.null(citation_yaml$`date-released`)) citation_yaml$`date-released` else format(Sys.Date(), "%Y-%m-%d"),
      accessed = format(Sys.Date(), "%Y-%m-%d"),  # Use the current date for the access date
      `container-title` = "KODAQS Toolbox",  # Updated container title
      publisher = "GESIS – Leibniz Institute for the Social Sciences",
      URL = if (!is.null(citation_yaml$url)) citation_yaml$url else url  # Use URL from citation.cff or fallback to the url variable
    )
  )

  # Parse YAML metadata from the output file
  output_yaml <- rmarkdown::yaml_front_matter(output_file)

  # Merge output metadata with the new citation metadata
  merged_yaml <- modifyList(output_yaml, citation_metadata)

  # Convert the merged YAML back to string format
  yaml_str <- yaml::as.yaml(merged_yaml)

  # Read the entire content of the output file
  output_content <- readLines(output_file)

  # Locate the YAML front matter delimiters
  yaml_start <- which(output_content == "---")[1]
  yaml_end <- which(output_content == "---")[2]

  # Extract the body content
  body_content <- if (!is.na(yaml_end)) output_content[(yaml_end + 1):length(output_content)] else output_content

  # Combine the cleaned YAML metadata and the body content
  full_content <- c("---", yaml_str, "---", body_content)

  # Write the final content back to the output file
  writeLines(full_content, output_file)

  message("Citation metadata updated and saved to ", output_file)
}


# Enhanced function to check file/directory access and associated diagnostics
investigate_file_or_directory <- function(path) {

  logger::log_debug("\nStep 1: Checking ownership and permissions... {path}\n")
  # Check if the path exists
  if (!file.exists(path)) {
    stop("Path does not exist: ", path)
  }

  permissions <- system(paste("ls -ld", shQuote(path), "| awk '{print $1}'"), intern = TRUE)
  logger::log_debug(paste("permissions for", path, "are:",  permissions))

}





