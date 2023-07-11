PANDOC_CALL <- "pandoc --from docx --to markdown --standalone"

docx2md <- function(docx_filename) {
    system(paste(PANDOC_CALL, docx_filename), intern = TRUE)
}

test_that("DOCX with title", {
  raw_all_contributions <-
    md_from_docx <- docx2md("docx/title.docx")
    expected_md <- c(
        "---",
        "title: Foo Bar",
        "---",
        ""
    )
  expect_equal(all_contributions, expected_all_contributions)
})
