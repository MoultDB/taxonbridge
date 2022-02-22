#' Get all NCBI and GBIF taxonomic ranks
#'
#' @param x A tibble created with \code{load_taxonomies()} or \code{load_population()} or \code{load_sample()}.
#' @param GBIF A logical indicating whether GBIF taxonomic ranks are to be retrieved.
#' @param NCBI A logical indicating whether NCBI taxonomic ranks are to be retrieved.
#'
#' @return A list of tibble(s) assigned to the S3 class \code{one_rank} or to the S3 class \code{all_ranks}.
#' @details
#' This method returns taxonomic ranks aggregated by frequency for
#' data derived from the NCBI, the GBIF, or both.
#'
#' @export
#'
#' @examples
#' prepare_rank_dist(load_sample(), NCBI=TRUE, GBIF=TRUE)
#' prepare_rank_dist(load_sample(), NCBI=TRUE)
prepare_rank_dist <- function(x, GBIF=FALSE, NCBI=FALSE) {
  if (!is.logical(GBIF)) stop("Argument to GBIF parameter must be either TRUE or FALSE")
  if (!is.logical(NCBI)) stop("Argument to NCBI parameter must be either TRUE or FALSE")
  taxonRank <- ncbi_rank <- NULL
  if (GBIF && NCBI) {
    xout <- list("GBIF" = dplyr::count(x, taxonRank),"NCBI" = dplyr::count(x, ncbi_rank))
    xout <- lapply(xout, function(y) {colnames(y) <- c("Rank", "Frequency"); y})
    class(xout) <- "all_ranks"
    xout
  }
  else if (GBIF && !NCBI) {
    xout <- list("GBIF" = dplyr::count(x, taxonRank))
    xout <- lapply(xout, function(y) {colnames(y) <- c("Rank", "Frequency"); y})
    class(xout) <- "one_rank"
    xout
  }
  else if (!GBIF && NCBI) {
    xout <- list("NCBI" = dplyr::count(x, ncbi_rank))
    xout <- lapply(xout, function(y) {colnames(y) <- c("Rank", "Frequency"); y})
    class(xout) <- "one_rank"
    xout
  }
  else {
    stop("At least one argument has to be true")
  }
}

#' Get comparable NCBI and GBIF taxonomic ranks
#'
#' @param x A tibble created with \code{load_taxonomies()} or \code{load_population()} or \code{load_sample()}.
#' @param GBIF A logical indicating whether GBIF taxonomic ranks are to be retrieved.
#' @param NCBI A logical indicating whether NCBI taxonomic ranks are to be retrieved.
#'
#' @return A list of tibble(s) assigned to the S3 class \code{one_rank} or to the S3 class \code{all_ranks}.
#' @details
#' This method, like \code{prepare_rank_dist()}, returns taxonomic ranks aggregated by frequency for
#' data derived from the NCBI, the GBIF, or both. However, this method only retains
#' taxonomic ranks that have at least one NCBI and one GBIF representative.
#'
#' @export
#'
#' @examples
#' prepare_comparable_rank_dist(load_sample())
#' prepare_comparable_rank_dist(get_status(load_sample(), "accepted"), NCBI = FALSE)
prepare_comparable_rank_dist <- function(x, GBIF = TRUE, NCBI = TRUE) {
  if (!is.logical(GBIF)) stop("Argument to GBIF parameter must be either TRUE or FALSE")
  if (!is.logical(NCBI)) stop("Argument to NCBI parameter must be either TRUE or FALSE")
  G <- GBIF
  N <- NCBI
  similar <- c(intersect(x$taxonRank,x$ncbi_rank))
  x <- x[x$taxonRank %in% similar & x$ncbi_rank %in% similar,]
  xout <- prepare_rank_dist(x, G, N)
  xout
}
