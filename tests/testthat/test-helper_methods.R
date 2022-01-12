test_that("terms are converted", {
  x <- load_sample()
  x_pre <- length(grep(paste(c("Animalia","Plantae"), collapse = "|"), x$kingdom))
  x_changed <- term_conversion(x)
  x_post <- length(grep(paste(c("Metazoa","Viridiplantae"), collapse = "|"), x_changed$kingdom))
  expect_equal(x_pre,x_post)
})
