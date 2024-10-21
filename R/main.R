#' Main function to get third party resources
#'
#' @param content_contributions_filename Database with contributors
#'
#' @return
#' @export
#'
#' @examples
main <- function(config_filename = "config.yaml",
                 content_contributions_filename = "content-contributions.json",
                 all_cards_filename = "zettelkasten.json",
                 source_dir = ".") {


  # Read the YAML configuration file
  config <- yaml::read_yaml(config_filename)
  # debugging settings
  # Access the values under the 'testing' key
  testing_config <- config$testing
  is_minimal_example <- testing_config$minimal_example
  debug <- testing_config$debug
  # Set logging level based on the 'debug' value
  if (debug) {
    logger::log_threshold(logger::DEBUG)
  } else {
    logger::log_threshold(logger::INFO)
  }

  # environment_config
  environment_config <- config$environment
  if (environment_config$rootless) {
    # working_dir <- environment_config$working_dir
    docker_host <- environment_config$docker_host
    # hacked the docker rootless with this:
    print("setting DOCKER_HOST to rootless (export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock)")
    Sys.setenv(DOCKER_HOST = docker_host)
  }

  # Extract the stages to be executed from the config
  stages <- config$stages

  original_wd <- fs::path_real(".")

  source_dir |>
    fs::path_real() |>
    setwd()

  tools_data <- NA

  tryCatch(
  {
    # load contribution json file with all the git repositories
    content_contributions_list <- content_contributions_filename |>
      fs::path_real() |>
      jsonlite::read_json()

    content_contributions_df <- tibble::tibble(
      contributions = content_contributions_list
    ) |>
      tidyr::unnest_wider(contributions)

    tools_data <- content_contributions_df

    # breaks down the json file and prepares paths for organizing the later stages
    logger::log_info("STAGE: Preparing contributions")
    tools_data <- prepare_contributions(tools_data)

    # downloads the contributions from the github/gitlab repoitories
    if (any(stages == "download_contributions")) {
      logger::log_info("STAGE: Downloading contributions")
      tools_data <- download_contributions(tools_data)
    }
    if (is_minimal_example) {
      tmp_paths <- tools_data$tmp_path
      logger::log_info("downloaded contributions to {tmp_paths}")
      file_lists <- list.files(tools_data$tmp_path)
      logger::log_info("contribution files are {file_lists}")
    }

    # procures the commit id as a meta data for later rendering
    logger::log_info("STAGE: Adding git info to contributions")
    tools_data <- git_info_to_contributions(tools_data)

    # build the docker container (with executable code within the docker container)
    if (any(stages == "create_containers")) {
      logger::log_info("STAGE: Creating containers")
      tools_data <- create_containers(tools_data)
    } else {
      tools_data <- add_image_names(tools_data)
    }
    if (is_minimal_example) {
      image_name <- tools_data$docker_image
      logger::log_info("Build container {image_name}")
      files_in_container <- list_files_in_container(image_name, "/home/andrew")
      logger::log_info("contribution files are {files_in_container}")
    }


    # converts the file from quarto(or else) to markdown (WITHOUT executable code)
    # the produced quarto markdown files are in the directories without underscore
    if (any(stages == "render_contributions")) {
      logger::log_info("STAGE: Rendering contributions")
      tools_data <- render_contributions(tools_data)
    } else {
      # add fake build flag if render_contribution is to be skipped
      tools_data$status <- "Built"
    }
    if (is_minimal_example){
      render_at_dir <- fs::path(tools_data$domain)
      logger::log_info("Written markdown files (no exec code) {render_at_dir}")
    }

    # validation list for what was running
    if (any(stages == "render_report")) {
      logger::log_info("STAGE: Rendering report")
      tools_data <- render_report(tools_data)
    }

    # creates the yaml files for the inclusion tree
    if (any(stages == "generate_card_files")) {
      logger::log_info("STAGE: Generating card files")
      generate_card_files(all_cards_filename, is_minimal_example)
    }

    if (any(stages == "create_linklist")) {
      logger::log_info("STAGE: Creating Linklist")
      create_linklist(content_contributions_filename)

    }


  },
    error = function(e) {
      logger::log_error("{e}")
    }
  )

  setwd(original_wd)

  if (!is_minimal_example) {
    return(tools_data)
  } else {
    return("SUCCESSFULLY ran minimal example pipeline")
  }
}

list_files_in_container <- function(image, path) {

  # Run a container from the image in detached mode and get its ID
  container_id <- system(sprintf("docker run -d %s tail -f /dev/null", image), intern = TRUE)

  # Execute the ls command inside the running container
  command <- sprintf("docker exec %s ls -R %s", container_id, path)
  files <- system(command, intern = TRUE)

  # Stop and remove the container after use
  system(sprintf("docker stop %s", container_id), intern = TRUE)
  system(sprintf("docker rm %s", container_id), intern = TRUE)

  # Return the list of files
  return(files)
}
