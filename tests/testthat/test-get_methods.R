test_that("get_lineages() returns all and only all non-NA data points",
          {
            x <- load_sample()

            #Check for expected data
            relevant<- x[!is.na(x$taxonRank) & !is.na(x$ncbi_lineage_ranks), c("taxonRank", "ncbi_lineage_ranks")]
            expect_equal(nrow(get_lineages(x)), nrow(na.omit(relevant)))

            #Check for unexpected data
            irrelevant <- x[is.na(x$taxonRank) | is.na(x$ncbi_lineage_ranks), c("taxonRank", "ncbi_lineage_ranks")]
            expect_equal(nrow(get_lineages(irrelevant)), 0)

            #Check test arguments
            expect_equal(nrow(relevant)+nrow(irrelevant), nrow(x))
          })

