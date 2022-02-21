#' Generic for plot_mdb methods
#'
#' @param x An object of the class one_rank or the class all_ranks.
#' @return A `ggplot2` derived plot
#' @details
#' A generic with methods that plot `taxonbridge` data types (`one_rank` and `all_ranks`). These
#' data types are created by using the methods `prepare_rank_dist()` or `prepare_comparable_rank_dist()`.
#'
#' @export
#'
#' @examples
#' plot_mdb(prepare_rank_dist(load_sample(), NCBI = TRUE, GBIF = TRUE))
#' plot_mdb(prepare_comparable_rank_dist(load_sample()))
#' plot_mdb(prepare_rank_dist(get_status(load_sample(),status = "synonym"), NCBI = TRUE))
#' plot_mdb(prepare_comparable_rank_dist(get_validity(get_status(load_sample()), valid = TRUE)))
plot_mdb <- function(x) {
  UseMethod("plot_mdb")
}

#' @export
plot_mdb.default <- function (x) {
  if (!rje::is.subset(class(x), c("one_rank","all_ranks"))) {
    stop("plot_mdb() is not applicable to this object.")
  }
}

#' @export
plot_mdb.one_rank <- function (x) {
  Rank <- Frequency <- NULL
  x_name <- attr(x, "name")
  x <- as.data.frame(x[[1]])
  x <- stats::na.omit(x)
  x <- utils::head(dplyr::arrange(x, dplyr::desc(x$Frequency)),5)
  ggplot2::ggplot(stats::na.omit(x), ggplot2::aes(stats::reorder(Rank, -(Frequency)), Frequency, fill = stats::reorder(Rank,(-Frequency)))) +
    ggplot2::geom_bar(stat='identity') +
    ggplot2::geom_col() +
    ggplot2::labs(x = "Rank", fill = "Rank") +
    ggplot2::theme(axis.ticks.x = ggplot2::element_blank(),
          axis.text.x = ggplot2::element_blank(),
          plot.title.position = "plot",
          plot.title = ggplot2::element_text(hjust = 0.5))
}

#' @export
plot_mdb.all_ranks <- function (x) {
  Rank <- Frequency <- Taxonomy <- NULL
  x <- purrr::map_df(x, ~as.data.frame(.x), .id = "Taxonomy")
  x <- stats::na.omit(x)
  x <- utils::head(dplyr::arrange(x, dplyr::desc(x$Frequency)),10)
  ggplot2::ggplot(x, ggplot2::aes(stats::reorder(Rank,Frequency), Frequency, fill = Taxonomy)) +
  ggplot2::geom_col() +
  ggplot2::coord_polar(theta = "y") +
  ggplot2::labs(x = "Rank") +
  ggplot2::theme(plot.title.position = "plot",
        plot.title = ggplot2::element_text(hjust = 0.5))
}
