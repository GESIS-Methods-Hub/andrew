library(logger)

library(tidyverse)

all_contributions <- read_csv('content-contributions.csv')

pre_process_contributions_list <- function(contribution_row) {
    regex_match <- str_match(contribution_row, 'https://github.com/(.*).git')
    user_and_project <- regex_match[2]

    return(user_and_project)
}

all_contributions$slang <- apply(all_contributions, 1, pre_process_contributions_list)
all_contributions <- all_contributions |>
    separate(slang, c("user_name", "repository_name"), sep='/', remove=FALSE)
all_contributions$tmp_path <- str_c("_", all_contributions$slang)
all_contributions$https <- str_replace(all_contributions$link, '.git$', '')

download_contribution <- function(contribution_row) {
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

copy_single_asset <- function(asset_source_path) {
    # We use _ at the name of the temporary folders
    asset_target_path <- str_replace(asset_source_path, '^_', '')
    asset_target_dir <- dirname(asset_target_path)
    dir.create(asset_target_dir, recursive = TRUE)
    log_debug('Copying {asset_source_path} to {asset_target_path}')
    file.copy(asset_source_path, asset_target_path)
}

copy_all_assets <- function(contribution_row) {
    all_assets <- list.files(
        path = contribution_row["tmp_path"],
        pattern = "(png|jpg|jpeg)$",
        recursive = TRUE
    )
    all_assets <- file.path(contribution_row["tmp_path"], all_assets)
    log_debug('Found assets: {all_assets}')
    lapply(all_assets, copy_single_asset)
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
    file.copy(tmp_html_file_path, html_file_path, overwrite=TRUE)
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
    file.copy(tmp_md_file_path, md_file_path, overwrite=TRUE)
    system(paste("cp -r ", file.path(contribution_row["tmp_path"], 'index.markdown_strict_files'), contribution_row["slang"]))
    log_info('Created {md_file_path}.')
}

render_quarto_to_jupyter <- function(contribution_row) {
    tmp_jupyter_file_path <- file.path(contribution_row["tmp_path"], 'index.ipynb')
    jupyter_file_path <- file.path(contribution_row["slang"], 'index.ipynb')

    if (file.exists(jupyter_file_path)) {
        log_info('{md_file_path} exists. Skipping convertion to markdown.')
        return(0)
    }

    log_info('Converting {contribution_row["tmp_path"]}/index.qmd to Jupyter Notebook ...')
    setwd(contribution_row["tmp_path"])
    system(paste("jupytext --to ipynb index.qmd"))
    setwd('../..')
    file.copy(tmp_jupyter_file_path, jupyter_file_path, overwrite=TRUE)
    log_info('Created {jupyter_file_path}.')
}

render_jupyter_to_md <- function(contribution_row) {
    tmp_md_file_path <- file.path(contribution_row["tmp_path"], 'index.md')
    md_file_path <- file.path(contribution_row["slang"], 'index.md')

    log_info('Converting {contribution_row["tmp_path"]}/index.ipynb to markdown ...')
    setwd(contribution_row["tmp_path"])
    system(paste("quarto render index.ipynb --to md --metadata prefer-html:true"))
    setwd('../..')
    file.copy(tmp_md_file_path, md_file_path, overwrite=TRUE)
    system(paste("cp -r ", file.path(contribution_row["tmp_path"], 'index.markdown_strict_files'), contribution_row["slang"]))
    log_info('Created {md_file_path}.')
}

render_md_to_md <- function(contribution_row) {
    # When converting Markdown to Markdown, Pandoc will use a full name for the output. Because of this we append `-tmp`.
    tmp_md_file_path <- file.path(contribution_row["tmp_path"], 'index.md-tmp')
    md_file_path <- file.path(contribution_row["slang"], 'index.md')

    log_info('Converting {contribution_row["tmp_path"]}/index.md to markdown ...')
    setwd(contribution_row["tmp_path"])
    git_hash <- system("git rev-parse HEAD", intern = TRUE)
    git_date <- system('git log -1 --format="%as"', intern = TRUE)
    system(paste(
        "quarto",
        "render", "index.md",
        "--to", "md",
        "--metadata", "prefer-html:true",
        "--template", "../../_templates/methods_hub.md",
        "--output", "index.md-tmp",
        "--variable", paste0("github_https:", contribution_row["https"]),
        "--variable", paste0("github_user_name:", contribution_row["user_name"]),
        "--variable", paste0("github_repository_name:", contribution_row["repository_name"]),
        "--variable", paste0("git_hash:", git_hash),
        "--variable", paste0("git_date:", git_date),
        "--variable", "source_filename:index.md"
    ))
    setwd('../..')
    file.copy(tmp_md_file_path, md_file_path, overwrite=TRUE)
    # system(paste("cp -r ", file.path(contribution_row["tmp_path"], 'index.markdown_strict_files'), contribution_row["slang"]))
    log_info('Created {md_file_path}.')
}

render_md_to_quarto <- function(contribution_row) {
    tmp_qmd_file_path <- file.path(contribution_row["tmp_path"], 'index.md')
    qmd_file_path <- file.path(contribution_row["slang"], 'index.qmd')

    log_info('Converting {contribution_row["tmp_path"]}/index.md to Quarto ...')
    # Quarto can't convert .md to .qmd
    file.copy(tmp_qmd_file_path, qmd_file_path, overwrite=TRUE)
    log_info('Created {qmd_file_path}.')
}

render_md_to_jupyter <- function(contribution_row) {
    tmp_jupyter_file_path <- file.path(contribution_row["tmp_path"], 'index.ipynb')
    jupyter_file_path <- file.path(contribution_row["slang"], 'index.ipynb')

    log_info('Converting {contribution_row["tmp_path"]}/index.md to Jupyter Notebook ...')
    setwd(contribution_row["tmp_path"])
    system(paste("quarto convert index.md"))
    setwd('../..')
    file.copy(tmp_jupyter_file_path, jupyter_file_path, overwrite=TRUE)
    # system(paste("cp -r ", file.path(contribution_row["tmp_path"], 'index.markdown_strict_files'), contribution_row["slang"]))
    log_info('Created {jupyter_file_path}.')
}

quarto_to_portal <- function(contribution_row) {
    download_contribution(contribution_row)

    quarto_filename <- file.path(contribution_row["tmp_path"], 'index.qmd')
    jupyter_filename <- file.path(contribution_row["tmp_path"], 'index.ipynb')
    md_filename <- file.path(contribution_row["tmp_path"], 'index.md')

    dir.create(contribution_row["slang"], recursive = TRUE)

    # if (file.exists(quarto_filename)) {
    #     extract_r_dependencies_from_quarto(contribution_row)

    #     render_quarto_to_md(contribution_row)
    #     render_quarto_to_jupyter(contribution_row)
    # }

    # if (file.exists(jupyter_filename)) {
    #     # extract_r_dependencies_from_jupyter(contribution_row)

    #     render_jupyter_to_md(contribution_row)
    #     #render_jupyter_to_quarto(contribution_row)
    # }

    if (file.exists(md_filename)) {
        copy_all_assets(contribution_row)
        render_md_to_md(contribution_row)
        render_md_to_quarto(contribution_row)
        render_md_to_jupyter(contribution_row)
    }

    system(paste("git add ", contribution_row["slang"]))
}

invisible(apply(all_contributions, 1, quarto_to_portal))