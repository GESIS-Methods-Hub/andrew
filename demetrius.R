library(logger)

library(stringr)

all_contributions <- read.csv('content-contributions.csv', header=TRUE)

pre_process_contributions_list <- function(contribution_row) {
    regex_match <- str_match(contribution_row, 'https://github.com/(.*).git')
    user_and_project <- regex_match[2]

    return(user_and_project)
}

all_contributions$slang <- apply(all_contributions, 1, pre_process_contributions_list)

download_contribution <- function(contribution_row) {
    if (dir.exists(contribution_row["slang"])) {
        log_info('{contribution_row["slang"]} already exists. Skipping download of {contribution_row["link"]}.')
        return(0)
    }

    log_info('Downloading {contribution_row["link"]} ...')
    system(paste("git clone", contribution_row["link"], contribution_row["slang"]))
    log_info('Download of {contribution_row["link"]} completed.')
}

apply(all_contributions, 1, download_contribution)

test_line_and_install <- function(quarto_line) {
    regex_match <- str_match(quarto_line, 'library\\((.*)\\)')

    if (anyNA(regex_match)) {
        return(0)
    }

    if(!require(regex_match[2], character.only=TRUE)) {
        install.packages(regex_match[2])
    }
}

extract_r_dependencies_from_quarto <- function(contribution_row) {
    if (!dir.exists(contribution_row["slang"])) {
        log_info('{contribution_row["slang"]} does NOT exist. Skipping convertion to HTML.')
        return(0)
    }

    all_quarto_lines <- readLines(file.path(contribution_row["slang"], 'index.qmd'))
    lapply(all_quarto_lines, test_line_and_install)
}

render_quarto_to_html <- function(contribution_row) {
    if (!dir.exists(contribution_row["slang"])) {
        log_info('{contribution_row["slang"]} does NOT exist. Skipping convertion to HTML.')
        return(0)
    }

    log_info('Converting {contribution_row["slang"]}/index.qmd to HTML')
    setwd(contribution_row["slang"])
    system("quarto render index.qmd --to html")
    setwd('../..')
}

quarto_to_portal <- function(contribution_row) {
    html_file_path <- file.path(contribution_row["slang"], 'index.html'))
    if (file.exists(html_file_path) {
        log_info('{html_file_path} already exists. Skipping it.')
        return(0)
    }

    extract_r_dependencies_from_quarto(contribution_row)
    render_quarto_to_html(contribution_row)
}

apply(all_contributions, 1, quarto_to_portal)