#' Render single contribution
#'
#' @param contribution_row
#'
#' @return
#' @export
#'
#' @examples
render_single_contribution <- function(contribution_row) {
  RENDER_MATRIX <- list(
    'md'=c(
      'md2md.sh',
      'md2qmd.sh',
      'md2ipynb.sh'
    ),
    'qmd'=c(
      'qmd2md.sh',
      'qmd2qmd.sh',
      'qmd2ipynb.sh'
    ),
    'ipynb'=c(
      'ipynb2md.sh',
      'ipynb2qmd.sh',
      'ipynb2ipynb.sh'
    )
  )

  git_slang <- contribution_row['slang']
  file2render <- contribution_row['filename']
  file2render_extension <- contribution_row['filename_extension']
  github_https <- contribution_row['link']
  github_user_name <- contribution_row['user_name']
  github_repository_name <- contribution_row['repository_name']
  docker_image <- contribution_row['docker_image']

  fs::dir_create(git_slang)

  template_location <-
    system.file('templates', package = 'methodshub', mustWork = TRUE)
  docker_scripts_location <-
    system.file('docker-scripts', package = 'methodshub', mustWork = TRUE)
  output_location <- contribution_row['slang'] |>
    fs::path_real()

  logger::log_info('Location of template directory: {template_location}')
  logger::log_info('Location of docker_scripts directory: {docker_scripts_location}')
  logger::log_info('Location of output directory: {output_location}')

  sum_docker_return_value <- 0
  for (script in get(file2render_extension, RENDER_MATRIX)) {
    docker_call_template <- 'docker run \\
    --mount type=bind,source=${template_location},target=/home/methodshub/_templates \\
    --mount type=bind,source=${docker_scripts_location},target=/home/methodshub/_docker-scripts \\
    --mount type=bind,source=${output_location},target=/home/methodshub/_output \\
    ${docker_image} \\
    /bin/bash -c "./_docker-scripts/${script} ${github_https} ${github_user_name} ${github_repository_name} ${file2render}"'

    docker_call <- stringr::str_interp(
      docker_call_template,
      list(
        template_location = template_location,
        docker_scripts_location = docker_scripts_location,
        output_location = output_location,
        file2render = file2render,
        github_https = github_https,
        github_user_name = github_user_name,
        github_repository_name = github_repository_name,
        docker_image = docker_image,
        script = script
      )
    )

    docker_return_value <- system(docker_call)

    sum_docker_return_value <- sum_docker_return_value + docker_return_value
  }


  if(sum_docker_return_value == 0){
    build_status <- 'Built'
  }
  else{
    build_status <- 'Unavailable'
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
