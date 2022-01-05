test_that("Sample data is in the correct format",
          {
            x <- load_sample()
            x_table <- table(sapply(x,class))

            #Check dimensions
            expect_equal(dim(x), c(2000,20))

            #Check number of character type columns
            expect_equal(x_table["character"][[1]], 15)

            #Check number of numeric type columns
            expect_equal(x_table["numeric"][[1]], 5)
          })
