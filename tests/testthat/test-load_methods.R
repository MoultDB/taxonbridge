test_that("Sample data is in the correct format",
          {
            #Check dimensions
            expect_equal(dim(load_sample()), c(2000,20))
            #Check number of character type columns
            expect_equal(table(sapply(load_sample(),class))["character"][[1]], 15)
            #Check number of numeric type columns
            expect_equal(table(sapply(load_sample(),class))["numeric"][[1]], 5)
          })
