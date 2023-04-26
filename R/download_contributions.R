library(logger)

donwload_single_contribution <- function(contribution_row) {
    if (dir.exists(contribution_row["tmp_path"])) {
        log_info('{contribution_row["tmp_path"]} already exists.')
        log_info('Skipping download of {contribution_row["link"]}.')
        log_info('Updating copy of {contribution_row["link"]}.')
        setwd(contribution_row["tmp_path"])
        system(paste("git", "clean", "--force", "-x"))
        system(paste("git", "pull"))
        setwd("../..")
    } else {
        log_info('{contribution_row["tmp_path"]} not found.')
        log_info('Downloading {contribution_row["link"]} ...')
        system(paste("git clone", contribution_row["link"], contribution_row["tmp_path"]))
        log_info('Download of {contribution_row["link"]} completed.')
    }
}

download_contributions <- function(all_contributions) {
    all_contributions |>
        apply(1, donwload_single_contribution)

    return(all_contributions)
}