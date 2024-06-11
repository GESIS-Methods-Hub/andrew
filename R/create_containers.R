#' Add Docker container names in a standardized way (use this as alternative to building the images)
#' @param all_contributions
#' @return
#' @export
add_image_names <- function(all_contributions){
  all_contributions$docker_image <- all_contributions |>
    apply(1, construct_image_name)
  return(all_contributions)
}

#' Add Docker container names in a standardized way
#'
#' @param contribution_row
#'
#' @return
#' @export
construct_image_name <- function (contribution_row) {
  git_repo <- contribution_row["slang"]
  git_commit_sha <- contribution_row["git_sha"]

  docker_repository <- stringr::str_interp(
    "andrew/${git_repo}",
    list(git_repo = git_repo)
  ) |>
    stringr::str_to_lower()
  image_name <- stringr::str_interp(
    "${docker_repository}:${git_commit_sha}",
    list(
      docker_repository = docker_repository,
      git_commit_sha = git_commit_sha
    )
  )
  return(image_name)

}


#' Create container based on repository
#'
#' @param contribution_row
#'
#' @return
#' @export
#'
#' @examples
create_container_from_repo <- function(contribution_row) {
  if (contribution_row["source_type"] != "Git") {
    return(NA)
  }

  git_repo_url <- contribution_row["web_address"]
  # git_repo <- contribution_row["slang"]
  # git_commit_sha <- contribution_row["git_sha"]

  image_name <- construct_image_name(contribution_row)

  local_list_of_images <-
    system("docker image list --format 'table {{.Repository}},{{.Tag}}'",
      intern = TRUE
    ) |>
    I() |>
    readr::read_csv()

  matching_images <- local_list_of_images |>
    dplyr::filter(
      REPOSITORY == docker_repository,
      TAG == git_commit_sha
    )

  # checks if image exists locally in the docker environment
  if (nrow(matching_images) == 0) {
    repo2docker_call_template <- "repo2docker \\
    --no-run \\
    --user-name andrew \\
    --image-name ${image_name} \\
    ${git_repo_url}"

    repo2docker_call <- stringr::str_interp(
      repo2docker_call_template,
      list(
        image_name = image_name,
        git_repo_url = git_repo_url
      )
    )

    logger::log_debug("Building {image_name} ...")
    logger::log_debug("{repo2docker_call}")
    repo2docker_call_return_value <- system(repo2docker_call, intern = FALSE)
    if (repo2docker_call_return_value == 0) {
      logger::log_info("{image_name} built.")
    } else {
      logger::log_warn("{image_name} NOT built.")
      stop()
    }
  } else {
    logger::log_info("{image_name} already exists. Skipping build.")
  }

  return(image_name)
}

#' Create Docker containers for database
#'
#' @param all_contributions database
#'
#' @return
#' @export
#'
#' @examples
create_containers <- function(all_contributions) {
  logger::log_info("START creating containers from contributions")
  all_contributions$docker_image <- all_contributions |>
    apply(1, create_container_from_repo)

  logger::log_info("END creating containers from contributions")
  return(all_contributions)
}


