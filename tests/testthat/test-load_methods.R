test_that("moultdbtools::load_sample() is functional and the resulting tibble has the correct dimensions",
          {
            expect_equal(dim(load_sample()), c(2000,20))
          })
