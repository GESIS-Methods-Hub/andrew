library(logger)

get_last_commit_sha <- function(contribution_row) {
    repo <- git2r::repository(here::here(contribution_row["tmp_path"]))
    last_commit <- git2r::revparse_single(repo, 'HEAD')
    last_commit_sha <- git2r::sha(last_commit)

    return(last_commit_sha)
}

git_info_to_contributions <- function(all_contributions) {
    all_contributions$git_sha <- all_contributions |>
        apply(1, get_last_commit_sha)

    return(all_contributions)
}