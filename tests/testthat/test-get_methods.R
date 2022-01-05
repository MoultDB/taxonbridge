test_that("get_lineages() returns all and only all non-NA data points",
          {
            x <- load_sample()
            #Rows that should be returned
            relevant<- x[!is.na(x$taxonRank) & !is.na(x$ncbi_lineage_ranks), c("taxonRank", "ncbi_lineage_ranks")]
            #Rows that should not be returned
            irrelevant <- x[is.na(x$taxonRank) | is.na(x$ncbi_lineage_ranks), c("taxonRank", "ncbi_lineage_ranks")]

            #Check that all relevant rows are returned
            expect_equal(nrow(get_lineages(x)), nrow(relevant))

            #Check that all irrelevant rows are not returned
            expect_equal(nrow(get_lineages(irrelevant)), 0)

            #Check test arguments
            expect_equal(nrow(relevant)+nrow(irrelevant), nrow(x))
          })

test_that("get_status() returns all, one, or multiple statuses",
          {
            x <- load_sample()
            single_test <- unique(get_status(x, "accepted")[,"taxonomicStatus"])[[1]]
            NA_test <- unique(get_status(x, NA)[,"taxonomicStatus"])[[1]]
            case_test <- unique(get_status(x, c("SynOnym", "synonym"))[,"taxonomicStatus"])[[1]]
            all_test <- get_status(x, c(NA, "doubtful", "accepted", "proparte synonym", "synonym", "homotypic synonym", "heterotypic synonym"))

            #Check that the input is returned unchanged when the second argument is absent.
            expect_equal(get_status(x), x)

            #Check that a string returns a tibble filtered on the string
            expect_equal(single_test, "accepted")
            expect_equal(NA_test, as.character(NA))

            #Check that upper and lower case doesn't effect the results
            expect_equal(case_test, "synonym")

            #Check that the input is returned unchanged when all terms are used
            expect_equal(all_test, x)

            #Check that an incorrect term returns and error
            expect_error(get_status(x,"404"))

            #Check that incompatible input returns an error
            expect_error(get_status("404"))
          })

