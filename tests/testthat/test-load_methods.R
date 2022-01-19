test_that("load_sample() is functional",
          {
            expect_equal(dim(load_sample()), c(2000,20))
          })

test_that("load_population() is functional",
          {
            sample_data <- system.file("extdata", "sample.tsv.gz", package = "taxonbridge", mustWork = TRUE)
            expect_equal(load_sample(), load_population(sample_data))
          })

test_that("load_taxonomies() is functional",
          {
            GBIF_stub <- system.file("extdata", "GBIF_stub.tsv", package = "taxonbridge", mustWork = TRUE)
            NCBI_stub <- system.file("extdata", "NCBI_stub.tsv", package = "taxonbridge", mustWork = TRUE)
            expect_equal(dim(load_taxonomies(GBIF_stub, NCBI_stub)), c(4,20))
          })
