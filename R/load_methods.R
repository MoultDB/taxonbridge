#' Load and merge GBIF and NCBI taxonomic data
#'
#' @param GBIF_path Path to the GBIF backbone taxonomy (compressed or uncompressed).
#' @param NCBI_path Path to the NCBI taxonomy (compressed or uncompressed).
#'
#' @return A tibble containing merged GBIF and NCBI taxonomic data.
#'
#' @details
#' This method parses and merges a GBIF `Taxon.tsv` file (see `download_gbif()`) and
#' a Taxonkit (\url{https://bioinf.shenwei.me/taxonkit/download/}) output file obtained by running: `taxonkit list --ids 1 | taxonkit lineage
#' --show-lineage-taxids --show-lineage-ranks --show-rank --show-name > All.lineages.tsv` on NCBI data dump files (see `download_ncbi()`).
#'
#' @export
#'
#' @examples
#' \dontrun{load_taxonomies("path/to/GBIF/Taxon.tsv","path/to/NCBI-Taxonkit/All.lineages.tsv")}
#' \dontrun{load_taxonomies(download_gbif(), download_ncbi(taxonkitpath = "/path/to/taxonkit"))}
load_taxonomies <- function(GBIF_path, NCBI_path) {

  #Load NCBI data:
  NCBI <- vroom::vroom(NCBI_path, na = "", col_names = FALSE, show_col_types = FALSE)
  colnames(NCBI) <- c("ncbi_id","ncbi_lineage_names", "ncbi_lineage_ids", "canonicalName", "ncbi_rank", "ncbi_lineage_ranks")
  NCBI$canonicalName <- as.character(NCBI$canonicalName)
  NCBI_all_rows <- nrow(NCBI)
  NCBI_data <- NCBI[!is.na(NCBI$canonicalName),]
  NCBI_data$from_NCBI <- 1
  NCBI_filtered_rows <- nrow(NCBI_data)

  #Load GBIF data:
  GBIF <- vroom::vroom(GBIF_path, show_col_types = FALSE)
  GBIF <- GBIF[,c(1, 8, 12, 3:5, 15, 18:22, 9:11)]
  GBIF$canonicalName <- as.character(GBIF$canonicalName)
  GBIF_all_rows <- nrow(GBIF)
  GBIF_data <- GBIF[!is.na(GBIF$canonicalName),]
  GBIF_data$from_GBIF <- 1
  GBIF_filtered_rows <- nrow(GBIF_data)

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
#' @param x Path to a text file containing previously merged NCBI and GBIF taxonomies (compressed or uncompressed).
#'
#' @return A tibble containing merged GBIF and NCBI taxonomic data.
#' @export
#'
#' @details
#' This method imports a previously merged taxonomy from your file system. An
#' example of a previously merged taxonomy can be downloaded
#' from \url{https://drive.google.com/file/d/1gpvm9QKdOcuGo_cIXPkAgGlB-qfKZZU6/view?usp=sharing}.
#'
#' @examples
#' \dontrun{load_population("path/to/merged_taxonomies")}
load_population <- function(x) {
  vroom::vroom(x, na = "", show_col_types = FALSE)
}

#' Load a sample of previously merged GBIF and NCBI taxonomies
#'
#' @return A tibble containing a sample of merged GBIF and NCBI taxonomic data.
#' @details
#' This method returns a small subset of previously merged GBIF and NCBI taxonomies.
#' @export
#'
#' @examples
#' load_sample()
load_sample <- function() {
  sample_data <- system.file("extdata", "sample.tsv.gz", package = "taxonbridge", mustWork = TRUE)
  vroom::vroom(sample_data, na = "", show_col_types = FALSE)
}

#' Download the NCBI taxonomy
#'
#' @param taxonkitpath A string containing the full path to where `Taxonkit` is installed (optional).
#'
#' @return A character vector containing paths to the relevant downloaded and unzipped NCBI data dump files, or
#' if the `taxonkitpath` parameter was set, the path to `All.lineages.tsv`.
#'
#'@details
#' This method downloads a NCBI taxonomy archive file to a temporary directory,
#' extracts four files (`nodes.dmp`, `names.dmp`, `merged.dmp` and `deleted.dmp`)
#' from the downloaded archive file, and then removes the archive file. If the path
#' to a `Taxonkit` installation is supplied, `Taxonkit` is called and the location of
#' the four files is passed to `Taxonkit` as an argument. Output is saved in the same
#' temporary folder in a file called `All.lineages.tsv`.
#'
#' @export
#'
#' @examples
#' \dontrun{download_ncbi()}
#' \dontrun{download_ncbi(taxonkitpath = "/home/usr/bin/taxonkit")}
download_ncbi <- function(taxonkitpath = NA) {
  if (!is.na(taxonkitpath)) {
    if (!grepl("taxonkit", tolower(taxonkitpath), fixed=TRUE)) {
      stop("The path must include both the directory name and filename 'taxonkit'")
    }
    tryCatch(
      expr = {
        system(paste0(taxonkitpath, " version"))
        message("Taxonkit detected!")
      },
      warning = function(e){
        stop(paste("Taxonkit not detected. Is this the correct path to Taxonkit:", taxonkitpath, "?"))
      })
  }
  current_t <- getOption("timeout")
  message("Your current download timeout is set to ",toString(current_t)," seconds.")
  withr::local_options(list(timeout = 600))
  new_t <- getOption("timeout")
  message("Temporarily setting the download timeout to ",toString(new_t)," seconds.")
  tf <- tempfile()
  td <- tempdir()
  url1 <- "https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdmp.zip"
  utils::download.file(url1,tf)
  files <- utils::unzip(tf, files = c("names.dmp","nodes.dmp","delnodes.dmp", "merged.dmp"), exdir = td )
  message("NCBI data dump has been downloaded and extracted.")
  if (!is.na(taxonkitpath)) { tryCatch(
      expr = {
        system(paste0("cd ", td,";",taxonkitpath," --data-dir=", file.path(td) ," list --ids 1 | ",taxonkitpath ," lineage --show-lineage-taxids --show-lineage-ranks --show-rank --show-name --data-dir=", file.path(td) ," > All.lineages.tsv"))
        unlink(tf)
        message("NCBI files parsed and result saved.")
        location <- file.path(td, "All.lineages.tsv")
        location
      },
      warning = function(e){
        message("Double check the directory name you supplied and/or your write permissions!")
      })
  }
    else {
      files
    }
}

#' Download the GBIF backbone taxonomy
#'
#' @return A string containing the path to `Taxon.tsv`.
#'
#' @details
#' This method downloads the GBIF backbone taxonomy archive file to a temporary directory,
#' extracts `Taxon.tsv` from the downloaded archive file, and then removes the archive file.
#'
#'
#' @export
#'
#' @examples
#' \dontrun{download_gbif()}
download_gbif <- function() {
  current_t <- getOption("timeout")
  message("Your current download timeout is set to ",toString(current_t)," seconds.")
  withr::local_options(list(timeout = 1800))
  new_t <- getOption("timeout")
  message("Temporarily setting the download timeout to ",toString(new_t)," seconds.")
  tf <- tempfile()
  td <- tempdir()
  url1 <- "https://hosted-datasets.gbif.org/datasets/backbone/current/backbone.zip"
  utils::download.file(url1,tf)
  files <- utils::unzip(tf, files = c("backbone/Taxon.tsv"), exdir = td)
  message("GBIF data dump has been downloaded and extracted.")
  unlink(tf)
  message("NOTE: Taxon.tsv is stored at ", files)
  files
}
