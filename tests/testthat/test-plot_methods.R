test_that("plot_mdb()",
          {
            x <- load_sample()
            x_get_methods <- get_status(get_validity(get_lineages(term_conversion(x))))
            x_one_rank <- prepare_rank_dist(x_get_methods, GBIF = TRUE)
            x_two_ranks <- prepare_rank_dist(x_get_methods, GBIF = TRUE, NCBI = TRUE)
            x_all_ranks <- prepare_comparable_rank_dist(x_get_methods)

            #S3 default method on error behavior
            expect_error(plot_mdb(x_get_methods))

            #S3 non-default methods create plot objects
            expect_equal(attr(plot_mdb(x_one_rank),"class")[1], "gg")
            expect_equal(attr(plot_mdb(x_two_ranks),"class")[1], "gg")
            expect_equal(attr(plot_mdb(x_all_ranks),"class")[1], "gg")
          })
