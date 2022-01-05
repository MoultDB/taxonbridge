#' Validate entries of a merged taxonomy
#'
#' @param x A tibble created with `load_taxonomies()` or `load_population()` or `load_sample()`.
#' @param valid A logical indicating whether the returned data should include valid or invalid entries (defaults to valid).
#' @param rank A string with GBIF rank that will be used to examine an NCBI lineage for validation purposes. Must
#' be "phylum", "class", "order" or "family". Defaults to family.
#'
#' @return A validated tibble
#' @export
#'
#' @examples
#' get_validity(load_sample(), valid = TRUE)
get_validity <- function(x,  valid = TRUE , rank = "family") {
  usablecolumns <- c("phylum", "class", "order", "family")
  userdefinedcolumn <- tolower(toString(rank))
  if (!rje::is.subset(userdefinedcolumn,usablecolumns)) {
    stop(paste0("Rank must be one of: ", toString(usablecolumns)))
  }
  x <- get_lineages(x)
  query_list <- strsplit(x$ncbi_lineage_names, split = ";")
  target_list <- dplyr::pull(x, userdefinedcolumn)
  lgl_vec <- c()
  for (i in 1:length(target_list)) {
    bool <- rje::is.subset(target_list[i],query_list[[i]])
    lgl_vec <- append(lgl_vec, bool)
  }
  if (valid) {
    xout <- x[which(lgl_vec),] }
  else {xout <- x[which(!lgl_vec),] }
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
  if (!dim(x)[2]==20) {
    stop("Input data doesn't have the expected number of columns")}
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
  }
  xout
}
