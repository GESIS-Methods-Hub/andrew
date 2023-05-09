test_that("csv with single line", {
  raw_all_contributions <-
    tibble::tibble(link = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md.git"
    ))
  expected_all_contributions <- tibble::tibble(
    link = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md.git"
    ),
    user_name = c("GESIS-Methods-Hub"),
    repository_name = c("minimal-example-md"),
    slang = c("GESIS-Methods-Hub/minimal-example-md"),
    tmp_path = c("_GESIS-Methods-Hub/minimal-example-md"),
    https = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md"
    ),
  )
  all_contributions <- prepare_contributions(raw_all_contributions)
  expect_equal(all_contributions, expected_all_contributions)
})

test_that("csv with single line without .git", {
  raw_all_contributions <-
    tibble::tibble(link = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md"
    ))
  expected_all_contributions <- tibble::tibble(
    link = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md"
    ),
    user_name = c("GESIS-Methods-Hub"),
    repository_name = c("minimal-example-md"),
    slang = c("GESIS-Methods-Hub/minimal-example-md"),
    tmp_path = c("_GESIS-Methods-Hub/minimal-example-md"),
    https = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md"
    ),
  )
  all_contributions <- prepare_contributions(raw_all_contributions)
  expect_equal(all_contributions, expected_all_contributions)
})
test_that("csv with two line", {
  raw_all_contributions <-
    tibble::tibble(
      link = c(
        "https://github.com/GESIS-Methods-Hub/minimal-example-md.git",
        "https://github.com/GESIS-Methods-Hub/minimal-example-qmd-rstats.git"
      )
    )
  expected_all_contributions <- tibble::tibble(
    link = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md.git",
      "https://github.com/GESIS-Methods-Hub/minimal-example-qmd-rstats.git"
    ),
    user_name = c("GESIS-Methods-Hub", "GESIS-Methods-Hub"),
    repository_name = c("minimal-example-md", "minimal-example-qmd-rstats"),
    slang = c(
      "GESIS-Methods-Hub/minimal-example-md",
      "GESIS-Methods-Hub/minimal-example-qmd-rstats"
    ),
    tmp_path = c(
      "_GESIS-Methods-Hub/minimal-example-md",
      "_GESIS-Methods-Hub/minimal-example-qmd-rstats"
    ),
    https = c(
      "https://github.com/GESIS-Methods-Hub/minimal-example-md",
      "https://github.com/GESIS-Methods-Hub/minimal-example-qmd-rstats"
    ),
  )
  all_contributions <- prepare_contributions(raw_all_contributions)
  expect_equal(all_contributions, expected_all_contributions)
})
