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
#' @param sensitivity An integer representing character mismatch tolerance. Defaults to intolerant i.e. sensitivity=0.
#' @param allow_term_removal A logical indicating whether searches against only the first word of `term`
#' should be carried out if no matches are found. Defaults to FALSE.
#' @param force_binomial A logical indicating whether `term` should be stripped
#' to a maximum of two words. Defaults to FALSE.
#'
#' @return A list of candidate match(es), if applicable.
#'
#' @details
#' The `sensitivity` parameter sets the number of character mismatches that are tolerated for
#' a match to be reported. The higher the sensitivity, the more matches will be found, but the
#' less relevant they may be. The `allow_term_removal` parameter allows stripping the search query
#' to only retain the characters before the first occurrence of a white space i.e. only the first
#' word of a search query is used during the search. This is useful when "Genus sp." or "Genus indet." is
#' the search query. However, `fuzzy_search()` will always search using the entire search query first and
#' then only proceed to strip terms if no hits are found. On the other hand, if `force_binomial` is set to TRUE,
#' the search query will first be limited to the first two words before searching commences. This in turn is useful
#' if the search query includes credit to the publisher e.g. "Birgus latro (Linnaeus, 1767)" or to
#' prevent subspecies names (so-called trinomials) from leading to a match not being made.
#'
#' @export
#'
#' @examples
#' fuzzy_search(load_sample(), "Miacis deutschi")
#' fuzzy_search(load_sample(), "Miacis sp.", allow_term_removal = TRUE)
#' fuzzy_search(load_sample(), "Miacus deutschi", sensitivity = 1)
#' fuzzy_search(load_sample(), "Miacis deutschi (Smith, 2022)", force_binomial = TRUE)
fuzzy_search <- function(x, term, sensitivity = 0, allow_term_removal = FALSE, force_binomial = FALSE) {
  canonicalName <- NULL
  term_l <- tolower(term)
  if (force_binomial) {
    term_l <- sub("^(\\S*\\s+\\S+).*", "\\1", term_l)
  }
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

#' Annotate a custom taxonomy
#'
#' @param x A tibble with taxonomic data to be annotated.
#' @param names A character vector containing scientific names that will be matched to scientific names in `x`.
#' @param new_column A string to be the name of a new column that will contain annotations.
#' @param present A string with the annotation in the case of a match (Defaults to "1").
#' @param absent A string with the annotation in case of no match (Defaults to NA).
#'
#' @return A tibble that contains an additional column with annotations.
#' @details
#' This method takes as input a character vector with scientific names. If the
#' scientific name(s) in the vector match with scientific names in the tibble, a new
#' column will be created and an annotation of choice will be added to the relevant row
#' in the new column. This method is useful for annotating scientific names with identified
#' ambiguity, duplication or any other characteristic. The character vector could, for example,
#' even contain scientific names that have not been derived with a Taxonbridge method.
#'
#' @export
#'
#' @examples
#'sample <- load_sample()
#'lineages <- get_lineages(sample)
#'kingdom <- get_validity(lineages, rank = "kingdom", valid = FALSE)
#'family <- get_validity(lineages, rank = "family", valid = FALSE)
#'candidates <- list(kingdom, family)
#'binomials <- get_inconsistencies(candidates, uninomials = FALSE, set = "intersect")
#'x <- annotate(sample, binomials, new_column = "inconsistencies", "Accepted but ambigious")
#'x[!is.na(x$inconsistencies),c("inconsistencies")]
annotate <- function(x, names, new_column, present = "1", absent = NA) {
  match_index <- which(tolower(x$canonicalName) %in% tolower(names))
  if (length(match_index)>0) {
    x[toString(new_column)] <- absent
    x[match_index,ncol(x)] <- present
    message(toString(length(match_index)), " annotations were made.")
  }
  else {
    message("No annotations were made since no matching names were found.")
  }
  x
}

#' Remove duplicate scientific names in a taxonomy
#'
#' @param x A tibble created with `load_taxonomies()` or `load_population()` or `load_sample()`.
#' @param ranked A logical indicating whether duplicates should be removed by certainty
#' of taxonomic status. Defaults to `TRUE`.
#'
#' @return A de-duplicated tibble
#' @details This method can be used in one of two ways. By simply passing a tibble as input,
#' duplicates will be stringently removed based on the following order: "accepted", "synonym","homotypic synonym",
#' "heterotypic synonym", "proparte synonym","doubtful", NA. If however the ranked parameter is set to `FALSE`,
#' duplicates will only be removed based on the scientific names, but not on taxonomic status, which results
#' in less duplicates being removed.
#'
#' @export

#' @examples
#' dedupe(load_sample())
dedupe <- function(x, ranked=TRUE) {
  start <- nrow(x)
  ranks = c("accepted", "synonym","homotypic synonym", "heterotypic synonym", "proparte synonym","doubtful", NA)
  if (!ranked) {
    xout <- x[!(duplicated(x[c("canonicalName","taxonomicStatus")]) | duplicated(x[c("canonicalName","taxonomicStatus")])), ]
    end <- nrow(xout)
  }
  else {
    x <- x[order(match(x$taxonomicStatus, ranks)),]
    xout <- x[!(duplicated(x[c("canonicalName")])),]
    end <- nrow(xout)
  }
  message(start-end," duplicates removed")
  xout
}
