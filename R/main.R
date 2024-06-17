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

  # Extract the stages to be executed from the config
  stages <- config$stages

  original_wd <- fs::path_real(".")

  source_dir |>
    fs::path_real() |>
    setwd()

  contribution_report <- NA

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

    contribution_report <- content_contributions_df

    # breaks down the json file and prepares paths for organizing the later stages
    logger::log_info("STAGE: Preparing contributions")
    contribution_report <- prepare_contributions(contribution_report)

    # downloads the contributions from the github/gitlab repoitories
    if (any(stages == "download_contributions")) {
      logger::log_info("STAGE: Downloading contributions")
      contribution_report <- download_contributions(contribution_report)
    }

    # procures the commit id as a meta data for later rendering
    logger::log_info("STAGE: Adding git info to contributions")
    contribution_report <- git_info_to_contributions(contribution_report)

    # build the docker container (with executable code within the docker container)
    if (any(stages == "create_containers")) {
      logger::log_info("STAGE: Creating containers")
      contribution_report <- create_containers(contribution_report)
    } else {
      contribution_report <- add_image_names(contribution_report)
    }

    # converts the file from quarto to markdown (WITHOUT executable code)
    # the produced quarto markdown files are in the directories without underscore
    if (any(stages == "render_contributions")) {
      logger::log_info("STAGE: Rendering contributions")
      contribution_report <- render_contributions(contribution_report)
    } else {
      # add fake build flag if render_contribution is to be skipped
      contribution_report$status <- "Built"
    }

    # validation list for what was running
    if (any(stages == "STAGE: render_report")) {
      logger::log_info("Rendering report")
      contribution_report <- render_report(contribution_report)
    }

    # creates the yaml files for the inclusion tree
    if (any(stages == "STAGE: generate_card_files")) {
      logger::log_info("Generating card files")
      generate_card_files(all_cards_filename, is_minimal_example)
    }
  },
    error = function(e) {
      logger::log_error("{e}")
    }
  )

  setwd(original_wd)

  if (!is_minimal_example) {
    return(contribution_report)
  } else{
    return("SUCCESSFULLY ran minimal example pipeline")
  }
}


