#' Load and merge GBIF and NCBI taxonomic data
#'
#' `load_taxonomies()` parses and merges a GBIF `Taxon.tsv` file (available
#' within the \url{https://hosted-datasets.gbif.org/datasets/backbone/current/backbone.zip} archive) and
#' a Taxonkit (\url{https://bioinf.shenwei.me/taxonkit/download/}) output file obtained by running: `taxonkit list --ids 1 | taxonkit lineage
#' --show-lineage-taxids --show-lineage-ranks --show-rank --show-name > All.lineages.tsv`.
#'
#' @param GBIF_path Path to the GBIF backbone taxonomy (compressed or uncompressed).
#' @param NCBI_path Path to the NCBI taxonomy (compressed or uncompressed).
#'
#' @return A tibble containing merged GBIF and NCBI taxonomic data.
#' @export
#'
#' @examples
#' \dontrun{load_taxonomies("path/to/GBIF/Taxon.tsv","path/to/NCBI-Taxonkit/All.lineages.tsv")}
load_taxonomies <- function(GBIF_path, NCBI_path) {
  #Load GBIF data
  #Available at https://hosted-datasets.gbif.org/datasets/backbone/
  #Remove redundant and empty columns
  GBIF <- vroom::vroom(GBIF_path)
  GBIF <- GBIF[,c(1, 8, 12, 3:5, 15, 18:22, 9:11)]
  GBIF$canonicalName <- as.character(GBIF$canonicalName)
  GBIF_all_rows <- nrow(GBIF)
  GBIF_data <- GBIF[!is.na(GBIF$canonicalName),]
  GBIF_data$from_GBIF <- 1
  GBIF_filtered_rows <- nrow(GBIF_data)

  #Load NCBI data obtained from taxonkit with:
  #taxonkit list --ids 1 | taxonkit lineage --show-lineage-taxids --show-lineage-ranks --show-rank --show-name > all.lineage_extended.tsv
  #Rename NCBI "name" column to "canonicalName" for merger with identically named column in GBIF
  NCBI <- vroom::vroom(NCBI_path, na = "", col_names = FALSE)
  colnames(NCBI) <- c("ncbi_id","ncbi_lineage_names", "ncbi_lineage_ids", "canonicalName", "ncbi_rank", "ncbi_lineage_ranks")
  NCBI$canonicalName <- as.character(NCBI$canonicalName)
  NCBI_all_rows <- nrow(NCBI)
  NCBI_data <- NCBI[!is.na(NCBI$canonicalName),]
  NCBI_data$from_NCBI <- 1
  NCBI_filtered_rows <- nrow(NCBI_data)

  #Merge GBIF and NCBI on “canonicalName" having a value
  merged_set <- dplyr::full_join(GBIF_data, NCBI_data)
  merged_rows <- nrow(merged_set)
  matched_rows <- nrow(merged_set[which(!is.na(merged_set$from_NCBI) & !is.na(merged_set$from_GBIF)),])

  message(toString(GBIF_filtered_rows), " of ", toString(GBIF_all_rows)," GBIF entries contained scientific names")
  message(toString(NCBI_filtered_rows), " of ", toString(NCBI_all_rows)," NCBI entries contained scientific names")
  message(toString(matched_rows), " matches on scientific names were made")

  attr(merged_set, "GBIF_all_rows") <- GBIF_all_rows
  attr(merged_set, "GBIF_filtered_rows") <- GBIF_filtered_rows
  attr(merged_set, "NCBI_all_rows") <- NCBI_all_rows
  attr(merged_set, "NCBI_filtered_rows") <- NCBI_filtered_rows
  attr(merged_set, "matched_rows") <- matched_rows
  merged_set
}


#' Load previously merged GBIF and NCBI taxonomies
#'
#' `load_population()` imports a previously merged taxonomy from your file system. An
#' example of an previously merged taxonomy can be downloaded
#' from \url{https://drive.google.com/file/d/1gpvm9QKdOcuGo_cIXPkAgGlB-qfKZZU6/view?usp=sharing}.
#'
#' @param x Path to a text file containing previously merged NCBI and GBIF taxonomies (compressed or uncompressed).
#'
#' @return A tibble
#' @export
#'
#' @examples
#' \dontrun{load_population("path/to/merged_taxonomies")}
load_population <- function(x) {
  vroom::vroom(x, na = "")
}

#' Load a sample of previously merged GBIF and NCBI taxonomies
#'
#' `load_sample()` returns a small subset of previously merged GBIF and NCBI taxonomies.
#'
#' @return A tibble containing a sample of merged GBIF and NCBI taxonomic data.
#' @export
#'
#' @examples
#' load_sample()
load_sample <- function() {
  sample_data <- system.file("extdata", "sample.tsv.gz", package = "taxonbridge", mustWork = TRUE)
  vroom::vroom(sample_data, na = "")
}
