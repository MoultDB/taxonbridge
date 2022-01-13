#' Convert GBIF terms to NCBI terms
#'
#' `term_conversion` converts GBIF terminology to NCBI terminology where there is
#' no biological provenance for the difference.
#'
#' @param x A tibble created with `load_taxonomies()` or `load_population()` or `load_sample()`.
#'
#' @return A tibble with converted terms.
#' @export
#'
#' @examples
#' term_conversion(load_sample())
term_conversion <- function(x) {
  to_metazoa <- replace(x$kingdom, x$kingdom=="Animalia", "Metazoa")
  x$kingdom <- to_metazoa
  to_viridiplantae <- replace(x$kingdom, x$kingdom=="Plantae", "Viridiplantae")
  x$kingdom <- to_viridiplantae
  attr(x, "converted") <- TRUE
  x
}
