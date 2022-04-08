#' Validate entries of a merged taxonomy
#'
#' @param x A tibble created with `load_taxonomies()` or `load_population()` or `load_sample()`.
#' @param valid A logical indicating whether the returned data should include valid or invalid entries (defaults to TRUE).
#' @param rank A string with GBIF rank that will be used to examine an NCBI lineage for validation purposes. Must
#' be kingdom, phylum, class, order or family. Defaults to family. Note: If "kingdom" is used, the
#' term_conversion() method should first be applied.
#'
#' @details
#' Taxonbridge matches NCBI and GBIF data by scientific name. This method will use the GBIF rank
#' (kingdom, phylum, class, order or family) and search for this rank name in the matched NCBI
#' lineage. The purpose is to detect scientific names that have different lineage
#' data in the GBIF and NCBI. If the `valid` parameter is set to TRUE, this method will
#' not only check the rank names, but also ensure that the GBIF `taxonRank` column and
#' NCBI `ncbi_rank` column matches.
#'
#' @return A validated tibble.
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
    xout <- x[which(lgl_vec),]
    xout <- xout[xout$taxonRank==xout$ncbi_rank,]
    }
  else {xout <- x[which(!lgl_vec),] }
  attr(xout, "got_validated") <- TRUE
  xout
}

#' Get entries that have lineage information for both the GBIF and NCBI data
#'
#' @param x A tibble created with `load_taxonomies()` or `load_population()` or `load_sample()`.
#'
#' @return A tibble with complete lineage data.
#' @export
#'
#' @examples
#' get_lineages(load_sample())
get_lineages <- function(x) {
  Remove_empty_GBIF <- x[!is.na(x$taxonRank),]
  Remove_empty_NCBI <- Remove_empty_GBIF[!is.na(Remove_empty_GBIF$ncbi_lineage_ranks),]
}


#' Filter a custom taxonomy by GBIF taxonomic status/synonym
#'
#' @param x A tibble created with \code{load_taxonomies()} or \code{load_population()} or \code{load_sample()}.
#' @param status Filter on GBIF assigned status (i.e. NA, "doubtful", "accepted", "proparte synonym", "synonym", "homotypic synonym",
#' "heterotypic synonym"). Can be a string or a vector of strings. Defaults to no filtering.
#'
#' @return A filtered tibble.
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

#' Detect candidate inconsistencies and ambiguity between NCBI and GBIF data
#'
#' @param x A **list** consisting of two tibbles of different ranks that have been passed to `get_validated(..., rank = ...)`.
#' @param uninomials A logical indicating whether uninomials should be included in the detection. Defaults to TRUE.
#' Note: uninomials are single names (e.g., "Coenobitidae").
#' @param set The type of set operation to be performed on `x` ("intersect", "union", or "setdiff").
#' Defaults to intersect. Note: the set difference ("setdiff") argument is order dependent.
#'
#' @return A character vector containing scientific names that exhibit inconsistency or ambiguity.
#'
#' @details This method will return the intersect, union, or set difference of a list of two
#' tibbles, and is meant to be used on lists of tibbles that have already been
#' processed with `get_validity()`. A list consisting of a single tibble may be passed to this method for the
#' purpose of retrieving a character vector containing scientific names, however, set operations do not apply
#' to lists consisting of single tibbles.
#'
#'
#' @export
#'
#' @examples
#'sample <- load_sample()
#'lineages <- get_lineages(sample)
#'kingdom <- get_validity(lineages, rank = "kingdom", valid = FALSE)
#'family <- get_validity(lineages, rank = "family", valid = FALSE)
#'candidates <- list(kingdom, family)
#'get_inconsistencies(candidates, uninomials = FALSE, set = "intersect")
get_inconsistencies <- function(x, uninomials = TRUE, set = "intersect") {
  canonicalName <- NULL
  candidates <- lapply(x, function(y) dplyr::pull(y, canonicalName))
  if (set=="intersect") {
  candidate_intersect <- Reduce(intersect, candidates)
  xout <- candidate_intersect
    if (!uninomials) {
      xout <- candidate_intersect[which(purrr::map_dbl(strsplit(candidate_intersect, " "), length)>1)]
    }
  }
  if (set=="union") {
  candidate_union <- Reduce(union, candidates)
  xout <- candidate_union
    if (!uninomials) {
      xout <- candidate_union[which(purrr::map_dbl(strsplit(candidate_union, " "), length)>1)]
    }
  }
  if (set=="setdiff") {
  candidate_setdiff <- Reduce(setdiff, candidates)
  xout <- candidate_setdiff
    if (!uninomials) {
      xout <- candidate_setdiff[which(purrr::map_dbl(strsplit(candidate_setdiff, " "), length)>1)]
    }
  }
  xout
}

#' A helper function to filter on GBIF taxa names
#'
#' @param x A tibble created with \code{load_taxonomies()} or \code{load_population()} or \code{load_sample()}.
#' @param kingdom A string consisting of a scientific name.
#' @param phylum A string consisting of a scientific name.
#' @param class A string consisting of a scientific name.
#' @param order A string consisting of a scientific name.
#' @param family A string consisting of a scientific name.
#' @param genus A string consisting of a scientific name.
#' @param species A string consisting of a scientific name.
#'
#' @return A filtered tibble.
#' @export
#'
#' @examples
#' get_taxa(load_sample(), species = "hyalina")
get_taxa <- function(x, kingdom=NA, phylum=NA, class=NA, order=NA, family=NA, genus=NA, species=NA) {
  if (!is.na(kingdom)) {
    k <- kingdom
    x <- dplyr::filter(x, tolower(x$kingdom)==tolower(k)|tolower(x$ncbi_kingdom)==tolower(k))
  }
  if (!is.na(phylum)) {
    p <- phylum
    x <- dplyr::filter(x, tolower(x$phylum)==tolower(p)|tolower(x$ncbi_phylum)==tolower(p))
  }
  if (!is.na(class)) {
    c <- class
    x <- dplyr::filter(x, tolower(x$class)==tolower(c)|tolower(x$ncbi_class)==tolower(c))
  }
  if (!is.na(order)) {
    o <- order
    x <- dplyr::filter(x, tolower(x$order)==tolower(o)|tolower(x$ncbi_order)==tolower(o))
  }
  if (!is.na(family)) {
    f <- family
    x <- dplyr::filter(x, tolower(x$family)==tolower(f)|tolower(x$ncbi_family)==tolower(f))
  }
  if (!is.na(genus)) {
    g <- genus
    x <- dplyr::filter(x, tolower(x$genericName)==tolower(g)|tolower(x$ncbi_genus)==tolower(g))
  }
  if (!is.na(species)) {
    s <- species
    x <- dplyr::filter(x, tolower(x$specificEpithet)==tolower(s)|tolower(x$ncbi_species)==tolower(s))
  }
  x
}
