test_that("prepare_rank_dist() assigns correct classes and throws errors",
          {
            x <- load_sample()
            expect_equal(class(prepare_rank_dist(x, NCBI = TRUE)), "one_rank")
            expect_equal(class(prepare_rank_dist(x, GBIF = TRUE)), "one_rank")
            expect_equal(class(prepare_rank_dist(x, NCBI = TRUE, GBIF = TRUE)), "all_ranks")
            expect_error(prepare_rank_dist(x))
            expect_error(prepare_rank_dist(x, NCBI = FALSE, GBIF = FALSE))
            expect_error(prepare_rank_dist(x, GBIF = "GBIF"))
            expect_error(prepare_rank_dist(x, NCBI = "NCBI"))
          })

test_that("prepare_comparable_rank_dist() assigns correct class and throws errors",
          {
            x <- load_sample()
            expect_equal(class(prepare_comparable_rank_dist(x)), "all_ranks")
            expect_error(prepare_comparable_rank_dist(x, GBIF = "GBIF"))
            expect_error(prepare_comparable_rank_dist(x, NCBI = "NCBI"))
          })
