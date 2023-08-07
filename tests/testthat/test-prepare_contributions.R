test_that("csv with single line of GitHub", {
  raw_all_contributions <- tibble::tibble(
    link = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md.git"
    ),
    filename = c(
      "index.md"
    )
  )
  expected_all_contributions <- tibble::tibble(
    link = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md.git"
    ),
    filename = c(
      "index.md"
    ),
    domain = c("github.com"),
    user_name = c("GESIS-Methods-Hub"),
    repository_name = c("minimal-example-md"),
    slang = c("GESIS-Methods-Hub/minimal-example-md"),
    tmp_path = c("_github.com/GESIS-Methods-Hub/minimal-example-md"),
    https = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md"
    ),
    filename_extension = c("md"),
    source_type = c("Git")
  )
  all_contributions <- prepare_contributions(raw_all_contributions)
  expect_equal(all_contributions, expected_all_contributions)
})

test_that("csv with single line of GitHub without .git", {
  raw_all_contributions <- tibble::tibble(
    link = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md"
    ),
    filename = c(
      "index.md"
    )
  )
  expected_all_contributions <- tibble::tibble(
    link = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md.git"
    ),
    filename = c(
      "index.md"
    ),
    domain = c("github.com"),
    user_name = c("GESIS-Methods-Hub"),
    repository_name = c("minimal-example-md"),
    slang = c("GESIS-Methods-Hub/minimal-example-md"),
    tmp_path = c("_github.com/GESIS-Methods-Hub/minimal-example-md"),
    https = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md"
    ),
    filename_extension = c("md"),
    source_type = c("Git")
  )
  all_contributions <- prepare_contributions(raw_all_contributions)
  expect_equal(all_contributions, expected_all_contributions)
})

test_that("csv with two line of GitHub", {
  raw_all_contributions <-
    tibble::tibble(
      link = c(
        "https://github.com/GESIS-Methods-Hub/minimal-example-md.git",
        "https://github.com/GESIS-Methods-Hub/minimal-example-qmd-rstats.git"
      ),
      filename = c(
        "index.md",
        "index.qmd"
      )
    )
  expected_all_contributions <- tibble::tibble(
    link = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md.git",
      "https://github.com/GESIS-Methods-Hub/minimal-example-qmd-rstats.git"
    ),
    filename = c(
      "index.md",
      "index.qmd"
    ),
    domain = c("github.com", "github.com"),
    user_name = c("GESIS-Methods-Hub", "GESIS-Methods-Hub"),
    repository_name = c("minimal-example-md", "minimal-example-qmd-rstats"),
    slang = c(
      "GESIS-Methods-Hub/minimal-example-md",
      "GESIS-Methods-Hub/minimal-example-qmd-rstats"
    ),
    tmp_path = c(
      "_github.com/GESIS-Methods-Hub/minimal-example-md",
      "_github.com/GESIS-Methods-Hub/minimal-example-qmd-rstats"
    ),
    https = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md",
      "https://github.com/GESIS-Methods-Hub/minimal-example-qmd-rstats"
    ),
    filename_extension = c(
      "md",
      "qmd"
    ),
    source_type = c(
      "Git",
      "Git"
    )
  )
  all_contributions <- prepare_contributions(raw_all_contributions)
  expect_equal(all_contributions, expected_all_contributions)
})

test_that("csv with single line of GitLab", {
  raw_all_contributions <- tibble::tibble(
    link = c(
      "https://gitlab.com/GESIS-Methods-Hub/minimal-example-md.git"
    ),
    filename = c(
      "index.md"
    )
  )
  expected_all_contributions <- tibble::tibble(
    link = c(
      "https://gitlab.com/GESIS-Methods-Hub/minimal-example-md.git"
    ),
    filename = c(
      "index.md"
    ),
    domain = c("gitlab.com"),
    user_name = c("GESIS-Methods-Hub"),
    repository_name = c("minimal-example-md"),
    slang = c("GESIS-Methods-Hub/minimal-example-md"),
    tmp_path = c("_gitlab.com/GESIS-Methods-Hub/minimal-example-md"),
    https = c(
      "https://gitlab.com/GESIS-Methods-Hub/minimal-example-md"
    ),
    filename_extension = c("md"),
    source_type = c("Git")
  )
  all_contributions <- prepare_contributions(raw_all_contributions)
  expect_equal(all_contributions, expected_all_contributions)
})

test_that("csv with single line of Nextcloud ", {
  raw_all_contributions <- tibble::tibble(
    link = c(
      "https://nextcloud.com/index.php/s/kTHok9Qdo3P3HXx/download"
    ),
    filename = c(
      "index.docx"
    )
  )
  expected_all_contributions <- tibble::tibble(
    link = c(
      "https://nextcloud.com/index.php/s/kTHok9Qdo3P3HXx/download"
    ),
    filename = c(
      "index.docx"
    ),
    domain = c("nextcloud.com"),
    user_name = c(NA),
    repository_name = c(NA),
    slang = c(NA),
    tmp_path = c("_nextcloud.com"),
    https = c(NA),
    filename_extension = c("docx"),
    source_type = c("HTTP")
  ) |>
    dplyr::mutate(
      user_name = as.character(user_name),
      repository_name = as.character(repository_name),
    )
  all_contributions <- prepare_contributions(raw_all_contributions)
  expect_equal(all_contributions, expected_all_contributions)
})
