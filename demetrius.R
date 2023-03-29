library(logger)

library(stringr)

all_contributions <- read.csv('content-contributions.csv', header=TRUE)

pre_process_contributions_list <- function(contribution_row) {
    regex_match <- str_match(contribution_row, 'https://github.com/(.*).git')
    user_and_project <- regex_match[2]

    return(user_and_project)
}

all_contributions$slang <- apply(all_contributions, 1, pre_process_contributions_list)
all_contributions$tmp_path <- str_c("_", all_contributions$slang)

download_contribution <- function(contribution_row) {
    if (dir.exists(contribution_row["tmp_path"])) {
        log_info('{contribution_row["tmp_path"]} already exists. Skipping download of {contribution_row["link"]}.')
        return(0)
    }

    log_info('Downloading {contribution_row["link"]} ...')
    system(paste("git clone", contribution_row["link"], contribution_row["tmp_path"]))
    log_info('Download of {contribution_row["link"]} completed.')
}

test_line_and_install <- function(quarto_line) {
    regex_match <- str_match(quarto_line, 'library\\((.*)\\)')

    if(!anyNA(regex_match) && !require(regex_match[2], character.only=TRUE)) {
        install.packages(regex_match[2])
    }

    regex_match <- str_match(quarto_line, 'devtools::install')

    if(!anyNA(regex_match)) {
        eval(parse(text=quarto_line))
    }
}

extract_r_dependencies_from_quarto <- function(contribution_row) {
    if (!dir.exists(contribution_row["tmp_path"])) {
        log_info('{contribution_row["tmp_path"]} does NOT exist. Skipping convertion to HTML.')
        return(0)
    }

    quarto_filename <- file.path(contribution_row["tmp_path"], 'index.qmd')
    if (file.exists(quarto_filename)) {
       all_quarto_lines <- readLines()
       lapply(all_quarto_lines, test_line_and_install)
    }
}

render_quarto_to_html <- function(contribution_row) {
    tmp_html_file_path <- file.path(contribution_row["tmp_path"], 'index.html')
    html_file_path <- file.path(contribution_row["slang"], 'index.html')

    if (file.exists(html_file_path)) {
        log_info('{html_file_path} exists. Skipping convertion to HTML.')
        return(0)
    }

    log_info('Converting {contribution_row["tmp_path"]}/index.qmd to HTML ...')
    setwd(contribution_row["tmp_path"])
    system(paste("quarto render index.qmd --to html"))
    setwd('../..')
    file.copy(tmp_html_file_path, html_file_path)
    system(paste("cp -r ", file.path(contribution_row["tmp_path"], 'index_files'), contribution_row["slang"]))
    log_info('Created {html_file_path}.')
}

render_quarto_to_md <- function(contribution_row) {
    tmp_md_file_path <- file.path(contribution_row["tmp_path"], 'index.md')
    md_file_path <- file.path(contribution_row["slang"], 'index.md')

    if (file.exists(md_file_path)) {
        log_info('{md_file_path} exists. Skipping convertion to markdown.')
        return(0)
    }

    log_info('Converting {contribution_row["tmp_path"]}/index.qmd to markdown ...')
    setwd(contribution_row["tmp_path"])
    system(paste("quarto render index.qmd --to md --metadata prefer-html:true"))
    setwd('../..')
    file.copy(tmp_md_file_path, md_file_path)
    system(paste("cp -r ", file.path(contribution_row["tmp_path"], 'index.markdown_strict_files'), contribution_row["slang"]))
    log_info('Created {md_file_path}.')
}

render_quarto_to_ipynb <- function(contribution_row) {
    tmp_ipynb_file_path <- file.path(contribution_row["tmp_path"], 'index.ipynb')
    ipynb_file_path <- file.path(contribution_row["slang"], 'index.ipynb')

    if (file.exists(ipynb_file_path)) {
        log_info('{md_file_path} exists. Skipping convertion to markdown.')
        return(0)
    }

    log_info('Converting {contribution_row["tmp_path"]}/index.qmd to Jupyter Notebook ...')
    setwd(contribution_row["tmp_path"])
    system(paste("jupytext --to ipynb index.qmd"))
    setwd('../..')
    file.copy(tmp_ipynb_file_path, ipynb_file_path)
    log_info('Created {ipynb_file_path}.')
}

render_ipynb_to_md <- function(contribution_row) {
    tmp_md_file_path <- file.path(contribution_row["tmp_path"], 'index.md')
    md_file_path <- file.path(contribution_row["slang"], 'index.md')

    log_info('Converting {contribution_row["tmp_path"]}/index.md to markdown ...')
    setwd(contribution_row["tmp_path"])
    system(paste("quarto render index.ipynb --to md --metadata prefer-html:true"))
    setwd('../..')
    file.copy(tmp_md_file_path, md_file_path)
    system(paste("cp -r ", file.path(contribution_row["tmp_path"], 'index.markdown_strict_files'), contribution_row["slang"]))
    log_info('Created {md_file_path}.')
}

render_md_to_md <- function(contribution_row) {
    tmp_md_file_path <- file.path(contribution_row["tmp_path"], 'index.md')
    md_file_path <- file.path(contribution_row["slang"], 'index.md')

    log_info('Converting {contribution_row["tmp_path"]}/index.md to markdown ...')
    setwd(contribution_row["tmp_path"])
    system(paste("quarto render index.md --to md --metadata prefer-html:true"))
    setwd('../..')
    file.copy(tmp_md_file_path, md_file_path)
    system(paste("cp -r ", file.path(contribution_row["tmp_path"], 'index.markdown_strict_files'), contribution_row["slang"]))
    log_info('Created {md_file_path}.')
}

quarto_to_portal <- function(contribution_row) {
    download_contribution(contribution_row)

    quarto_filename <- file.path(contribution_row["tmp_path"], 'index.qmd')
    jupyter_filename <- file.path(contribution_row["tmp_path"], 'index.ipynb')
    md_filename <- file.path(contribution_row["tmp_path"], 'index.md')

    dir.create(contribution_row["slang"], recursive = TRUE)

    if (file.exists(quarto_filename)) {
        extract_r_dependencies_from_quarto(contribution_row)

        render_quarto_to_md(contribution_row)
        render_quarto_to_ipynb(contribution_row)
    }

    if (file.exists(jupyter_filename)) {
        # extract_r_dependencies_from_jupyter(contribution_row)

        render_jupyter_to_md(contribution_row)
        #render_jupyter_to_quarto(contribution_row)
    }

    if (file.exists(md_filename)) {
        render_md_to_md(contribution_row)
        #render_md_to_ipynb(contribution_row)
    }

    system(paste("git add ", contribution_row["slang"]))
}

invisible(apply(all_contributions, 1, quarto_to_portal))