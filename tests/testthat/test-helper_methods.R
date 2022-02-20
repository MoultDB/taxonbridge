test_that("terms are converted", {
  x <- load_sample()
  x_pre <- length(grep(paste(c("Animalia","Plantae"), collapse = "|"), x$kingdom))
  x_changed <- term_conversion(x)
  x_post <- length(grep(paste(c("Metazoa","Viridiplantae"), collapse = "|"), x_changed$kingdom))
  expect_equal(x_pre,x_post)
})

test_that("fuzzy_search() is functional", {
  x <- load_sample()
  expect_equal(length(fuzzy_search(x, "Degeeria decora")), 1)
  expect_equal(length(fuzzy_search(x, "Degeeria indet.", allow_term_removal = TRUE)), 1)
  expect_equal(length(fuzzy_search(x, "Degeeris indet.", sensitivity = 1, allow_term_removal = TRUE)), 1)
})
