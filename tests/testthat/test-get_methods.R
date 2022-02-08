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

test_that("get_status() is functional",
          {
            x <- load_sample()
            expect_error(get_status(x, c("doubtful", "duplicated")))
            expect_equal(nrow(get_status(x, c("doubtful", "accepted"))), 1260)
          })

test_that("get_validity() is functional",
          {
            x <- load_sample()
            expect_error(get_validity(x, rank = "species"))
            expect_message(get_validity(x, rank = "kingdom", valid = FALSE), "Term conversion carried out on kingdom taxonomic rank")
          })

test_that("get_inconsistencies() is functional",
          {
            x <- get_lineages(load_sample())
            kingdom <- get_validity(x, rank = "kingdom", valid = FALSE)
            family <- get_validity(x, rank = "family", valid = FALSE)
            candidates <- list(kingdom, family)
            expect_equal(length(get_inconsistencies(candidates, uninomials = FALSE)), 2)
          })
test_that("get_taxa() is functional",
          {
            x <- load_sample()
            expect_equal(nrow(get_taxa(x, kingdom = "Animalia",
                                  phylum = "Chordata",
                                  class = "Mammalia",
                                  order = "Carnivora",
                                  family = "Miacidae",
                                  genus = "Miacis",
                                  species = "deutschi" )), 1)
          })
