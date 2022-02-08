#' Validate entries of a merged taxonomy
#'
#' @param x A tibble created with `load_taxonomies()` or `load_population()` or `load_sample()`.
#' @param valid A logical indicating whether the returned data should include valid or invalid entries (defaults to valid).
#' @param rank A string with GBIF rank that will be used to examine an NCBI lineage for validation purposes. Must
#' be kingdom, phylum, class, order or family. Defaults to family. Note: If "kingdom" is used, the
#' term_conversion() method should first be applied.
#'
#' @return A validated tibble
#' @export
#'
#' @examples
#' get_validity(load_sample(), valid = TRUE)
get_validity <- function(x, rank = "family", valid = TRUE) {
  usablecolumns <- c("kingdom", "phylum", "class", "order", "family")
  userdefinedcolumn <- tolower(toString(rank))
  if (!rje::is.subset(userdefinedcolumn,usablecolumns)) {
    stop(paste0("Rank must be one of: ", toString(usablecolumns)))
  }
  if (userdefinedcolumn=="kingdom" && is.null(attr(x,"converted"))) {
    x <- term_conversion(x)
    message("Term conversion carried out on kingdom taxonomic rank")
  }
  x <- get_lineages(x)
  query_list <- strsplit(x$ncbi_lineage_names, split = ";")
  target_list <- dplyr::pull(x, userdefinedcolumn)
  lgl_vec <- unlist(purrr::map2(target_list, query_list, rje::is.subset))
  if (valid) {
    xout <- x[which(lgl_vec),] }
  else {xout <- x[which(!lgl_vec),] }
  attr(xout, "got_validated") <- TRUE
  xout
}

#' Get entries that have lineage information for both the GBIF and NCBI data
#'
#' @param x A tibble created with `load_taxonomies()` or `load_population()` or `load_sample()`.
#'
#' @return A tibble with complete lineage data
#' @export
#'
#' @examples
#' get_lineages(load_sample())
get_lineages <- function(x) {
  Remove_empty_GBIF <- x[!is.na(x$taxonRank),]
  Remove_empty_NCBI <- Remove_empty_GBIF[!is.na(Remove_empty_GBIF$ncbi_lineage_ranks),]
}


#' Filter a combined taxonomy by GBIF taxonomic status/synonym
#'
#' @param x A tibble created with \code{load_taxonomies()} or \code{load_population()} or \code{load_sample()}.
#' @param status Filter on GBIF assigned status (i.e. NA, "doubtful", "accepted", "proparte synonym", "synonym", "homotypic synonym",
#' "heterotypic synonym"). Can be a string or a vector of strings. Defaults to no filtering.
#'
#' @return A filtered tibble
#' @export
#'
#' @examples
#' get_status(load_sample(), "synonym")
#' get_status(load_sample(), c("accepted", "doubtful"))
get_status <- function (x, status = "all") {
  StatusVector <- c(tolower(status))
  if(!"all" %in% StatusVector) {
    GBIF_status <- c(NA, "doubtful", "accepted", "proparte synonym", "synonym", "homotypic synonym", "heterotypic synonym")
    if (!rje::is.subset(StatusVector,GBIF_status)) {
      stop(paste0("Status must be, and only be, one or more of: ", toString(GBIF_status)))
    }
    xout <- x[x$taxonomicStatus %in% StatusVector,]

  }
  else {
    xout <- x
    message("No filtering argument was passed to get_status()")
  }
  xout
}

#' Detect candidate inconsistencies and ambiguity
#'
#' @param x A list consisting of tibble(s) that have been passed to get_validated()
#' @param uninomials A Boolean indicating whether uninomials should be included in the detection (defaults to TRUE)
#'
#' @return A character vector containing scientific names that exhibit inconsistency or ambiguity
#' @export
#'
#' @examples
#'sample <- load_sample()
#'lineages <- get_lineages(sample)
#'kingdom <- get_validity(lineages, rank = "kingdom", valid = FALSE)
#'family <- get_validity(lineages, rank = "family", valid = FALSE)
#'candidates <- list(kingdom, family)
#'get_inconsistencies(candidates, uninomials = FALSE)
get_inconsistencies <- function(x, uninomials = TRUE) {
  canonicalName <- NULL
  candidates <- lapply(x, function(y) dplyr::pull(y, canonicalName))
  candidate_intersect <- Reduce(intersect, candidates)
  if (!uninomials) {
    xout <- candidate_intersect[which(purrr::map_dbl(strsplit(candidate_intersect, " "), length)>1)]
  }
  xout
}

#' A helper function to filter columns on GBIF taxa names
#'
#' @param x A tibble created with \code{load_taxonomies()} or \code{load_population()} or \code{load_sample()}.
#' @param kingdom A string consisting of a scientific name
#' @param phylum A string consisting of a scientific name
#' @param class A string consisting of a scientific name
#' @param order A string consisting of a scientific name
#' @param family A string consisting of a scientific name
#' @param genus A string consisting of a scientific name
#' @param species A string consisting of a scientific name
#'
#' @return A filtered tibble
#' @export
#'
#' @examples
#' get_taxa(load_sample(), species = "hyalina")
get_taxa <- function(x, kingdom=NA, phylum=NA, class=NA, order=NA, family=NA, genus=NA, species=NA) {
  if (!is.na(kingdom)) {
    x <- x[tolower(x$kingdom)==tolower(kingdom),]
    x <- x[!is.na(x$kingdom),]
  }
  if (!is.na(phylum)) {
    x <- x[tolower(x$phylum)==tolower(phylum),]
    x <- x[!is.na(x$phylum),]
  }
  if (!is.na(class)) {
    x <- x[tolower(x$class)==tolower(class),]
    x <- x[!is.na(x$class),]
  }
  if (!is.na(order)) {
    x <- x[tolower(x$order)==tolower(order),]
    x <- x[!is.na(x$order),]
  }
  if (!is.na(family)) {
    x <- x[tolower(x$family)==tolower(family),]
    x <- x[!is.na(x$family),]
  }
  if (!is.na(genus)) {
    x <- x[tolower(x$genericName)==tolower(genus),]
    x <- x[!is.na(x$genericName),]
  }
  if (!is.na(species)) {
    x <- x[tolower(x$specificEpithet)==tolower(species),]
    x <- x[!is.na(x$specificEpithet),]
  }
  xout <- x
  xout
}
