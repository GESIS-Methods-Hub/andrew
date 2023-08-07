#' Render single contribution
#'
#' @param contribution_row
#'
#' @return
#' @export
#'
#' @examples
render_single_contribution <- function(contribution_row) {
  logger::log_info("Rendering {contribution_row['filename']} from {contribution_row['link']}")

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

  logger::log_info("Location of docker_scripts directory: {docker_scripts_location}")
  logger::log_info("Location of pandoc_filters directory: {pandoc_filters_location}")
  logger::log_info("Location of output directory: {output_location}")
  logger::log_info("Location of output directory inside the container: {output_location_in_container}")

  sum_docker_return_value <- 0
  for (script in get(file2render_extension, RENDER_MATRIX)) {
    logger::log_info("Rendering using {script} ...")

    docker_call_template <- 'docker run \\
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

    docker_return_value <- system(docker_call)

    logger::log_info("Rendering complete. Docker returned {docker_return_value}.")

    sum_docker_return_value <- sum_docker_return_value + docker_return_value
  }

  if (sum_docker_return_value == 0) {
    build_status <- "Built"

    logger::log_info("Rendering PDF ...")

    host_user_id <- system("id -u", intern = TRUE)

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

    logger::log_info("Rendering PDF completed.")
  } else {
    build_status <- "Unavailable"
    logger::log_info("Skipping PDF rendering.")
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
