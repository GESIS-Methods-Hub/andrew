library(logger)

library(tidyverse)

content_contributions_filename <- 'content-contributions.csv'

content_contributions_filename |>
    here::here() |>
    read_csv() |>
    prepare_contributions()
