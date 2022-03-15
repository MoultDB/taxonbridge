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

test_that("annotation() is functional", {
  x <- load_sample()
  x <- annotate(x, "Degeeria decora", "test" )
  expect_equal(ncol(x), 21)
  expect_equal(nrow(x[!is.na(x$test),]), 1)
  expect_message(annotate(x, "Degejhwegjewgr", "test" ), "No annotations were made since no matching names were found.")
})

test_that("dedupe() is functional", {
  x <- load_sample()
  expect_equal(nrow(dedupe(x)), 1999)
  expect_equal(nrow(dedupe(x, ranked = FALSE)), 2000)
})
