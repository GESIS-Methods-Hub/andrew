PANDOC_CALL <- "pandoc --from docx+styles --to markdown --standalone --lua-filter ../../inst/pandoc-filters/remove-toc.lua"

docx2md <- function(docx_filename) {
    system(paste(PANDOC_CALL, docx_filename), intern = TRUE)
}

test_that("DOCX with title", {
  raw_all_contributions <-
    md_from_docx <- docx2md("../docx/title.docx")
    expected_md <- c(
        "---",
        "title: Foo Bar",
        "---",
        ""
    )
  expect_equal(md_from_docx, expected_md)
})

test_that("DOCX with section title", {
  raw_all_contributions <-
    md_from_docx <- docx2md("../docx/section-title.docx")
    expected_md <- c(
        "# Foo Bar"
    )
  expect_equal(md_from_docx, expected_md)
})

test_that("DOCX with table of content", {
  raw_all_contributions <-
    md_from_docx <- docx2md("../docx/toc.docx")
    expected_md <- c(
        "# Foo Bar"
    )
  expect_equal(md_from_docx, expected_md)
})
