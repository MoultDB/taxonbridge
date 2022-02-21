#' Convert GBIF terms to NCBI terms
#'
#' @param x A tibble created with `load_taxonomies()` or `load_population()` or `load_sample()`.
#'
#' @return A tibble with converted terms. The tibble is furthermore annotated with the
#' attribute `converted=TRUE`.
#'
#' @details
#' This method converts GBIF terminology to NCBI terminology where there is
#' no biological provenance for the difference. Specifically, "Animalia" is converted
#' to "Metazoa", and "Plantae" is converted to "Viridiplantae".
#'
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

#' Match misspelled or partial scientific names
#'
#' @param x A tibble created with \code{load_taxonomies()} or \code{load_population()} or \code{load_sample()}.
#' @param term A string consisting of a scientific name.
#' @param sensitivity An integer representing character mismatch tolerance (defaults to intolerant i.e. sensitivity=0)
#' @param allow_term_removal Allow searches against only the first word of a search query. Useful
#' when "Genus sp." or "Genus indet." is the search phrase.
#'
#' @return A list of candidate match(es), if applicable.
#'
#' @details
#' The `sensitivity` parameter sets the number of character mismatches that are tolerated for
#' a match to be reported. The higher the sensitivity, the more matches will be found, but the
#' less relevant they may be. The `allow_term_removal` parameter allows striping the search query
#' to only retain the characters before the first occurrence of a white space (i.e., only the first
#' word of a search query is used during the search). However, `fuzzy_search()` will always search
#' using the entire search query first and then only proceed to strips terms if no hits are found.
#'
#' @export
#'
#' @examples
#' fuzzy_search(load_sample(), "Miacis deutschi")
#' fuzzy_search(load_sample(), "Miacis sp.", allow_term_removal = TRUE)
#' fuzzy_search(load_sample(), "Miacus deutschi", sensitivity = 1)
fuzzy_search <- function(x, term, sensitivity = 0, allow_term_removal = FALSE) {
  message("NOTE: Fuzzy search may be slower than expected...")
  canonicalName <- NULL
  term_l <- tolower(term)
  matches <- agrep(term_l, tolower(x$canonicalName), max.distance = sensitivity, ignore.case = TRUE)
  if (length(matches)>0) {
    xout <- x[matches,]
    message("Candidate match(es) made on: ", toString(term))
    xout$canonicalName
  }
  else if (length(matches)==0) {
    term_l <- gsub( " .*$", "", term_l)
    if (allow_term_removal) {
    matches <- agrep(term_l, tolower(x$canonicalName), max.distance = sensitivity, ignore.case = TRUE)
    }
    if (length(matches)>0) {
      xout <- x[matches,]
      message("Candidate match(es) made by term removal on: ", toString(term))
      xout$canonicalName
    }
    else {
      message("No match(es) found for: ", toString(term))
    }
  }
}
