#' Load and merge GBIF and NCBI taxonomic data
#'
#' @param GBIF_path Path to the GBIF backbone taxonomy (compressed or uncompressed).
#' @param NCBI_path Path to the NCBI taxonomy (compressed or uncompressed).
#'
#' @return A tibble containing merged GBIF and NCBI taxonomic data.
#'
#' @details
#' This method merges a GBIF `Taxon.tsv` file (see `download_gbif()`) and
#' a Taxonkit (\url{https://bioinf.shenwei.me/taxonkit/download/}) output file (see `download_ncbi()`).
#'
#' @export
#'
#' @examples
#' \dontrun{load_taxonomies("path/to/GBIF/Taxon.tsv","path/to/NCBI-Taxonkit/All.lineages.tsv")}
#' \dontrun{load_taxonomies(download_gbif(), download_ncbi(taxonkitpath = "/path/to/taxonkit"))}
load_taxonomies <- function(GBIF_path, NCBI_path) {

  #Load NCBI data:
  NCBI <- vroom::vroom(NCBI_path, na = "", col_names = FALSE, col_types = vroom::cols(.default = "c"))
  NCBI_col7 <- do.call(rbind, stringr::str_split(NCBI$X7, ";"))
  NCBI <- cbind(NCBI[,1:6], NCBI_col7)
  NCBI <- dplyr::mutate_all(NCBI, list(~dplyr::na_if(.,"")))
  remove(NCBI_col7)
  colnames(NCBI) <- c("ncbi_id","ncbi_lineage_names", "ncbi_lineage_ids", "canonicalName",
                      "ncbi_rank", "ncbi_lineage_ranks", "ncbi_kingdom", "ncbi_phylum",
                      "ncbi_class", "ncbi_order", "ncbi_family", "ncbi_genus", "ncbi_species")
  NCBI_all_rows <- nrow(NCBI)
  NCBI_data <- NCBI[!is.na(NCBI$canonicalName),]
  NCBI_data$from_NCBI <- as.character(1)
  NCBI_filtered_rows <- nrow(NCBI_data)

  #Load GBIF data:
  GBIF <- vroom::vroom(GBIF_path, col_types = vroom::cols(.default = "c"), quote = "")
  GBIF <- GBIF[,c(1, 8, 12, 3:5, 15, 18:22, 9:11)]
  GBIF_all_rows <- nrow(GBIF)
  GBIF_data <- GBIF[!is.na(GBIF$canonicalName),]
  GBIF_data$from_GBIF <- as.character(1)
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
  vroom::vroom(x, show_col_types = FALSE, col_types = vroom::cols(.default = "c"))
}

#' Load an example of previously merged GBIF and NCBI taxonomies
#'
#' @return A tibble containing a sample of merged GBIF and NCBI taxonomic data.
#' @details
#' This method returns a small subset of previously merged GBIF and NCBI taxonomies. The
#' subset is an example dataset that is only meant to be used to familiarize yourself
#' with `taxonbridge` methods.
#' @export
#'
#' @examples
#' load_sample()
load_sample <- function() {
  sample_data <- system.file("extdata", "sample.tsv.gz", package = "taxonbridge", mustWork = TRUE)
  x <- vroom::vroom(sample_data, na = "", col_types = vroom::cols(.default = "c"))
  message("\n#####  ##   #    #   ###   #    #  ####   ####   #####  ####    #####  #####")
  message("  #   #  #   #  #   #   #  ##   #  #   #  #   #    #    #   #   #      #    ")
  message("  #   ####    #     #   #  # #  #  #####  #####    #    #    #  #  ##  #####")
  message("  #   #  #   #  #   #   #  #  # #  #   #  #  #     #    #   #   #   #  #    ")
  message("  #   #  #  #    #   ###   #    #  ####   #   #  #####  ####    #####  #####\n")
  message("A sample containing 2000 rows by 29 columns has been loaded.")
  message("Visit the following links to learn more about Taxonbridge:")
  message("https://github.com/MoultDB/taxonbridge#available-methods-and-how-to-use-them")
  message("https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_workflow.pdf")
  message("https://rdocumentation.org/packages/taxonbridge/")
  message("https://CRAN.R-project.org/package=taxonbridge")
  x
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
#' extracts four files (`nodes.dmp`, `names.dmp`, `merged.dmp` and `delnodes.dmp`)
#' from the downloaded archive file, and then removes the archive file. Further parsing of
#' these four files must be carried out with Taxonkit (\url{https://bioinf.shenwei.me/taxonkit/download/}),
#' either automatically or manually. If the path to a Taxonkit installation is supplied, Taxonkit is
#' called and the location of the four files is passed to Taxonkit as an argument for automatic parsing.
#' Taxonkit output is saved in the same temporary folder in a file called `All.lineages.tsv`.
#' If the path to Taxonkit is not supplied, parsing should be carried out manually using the command:
#' `taxonkit list --ids 1 | taxonkit lineage --show-lineage-taxids --show-lineage-ranks --show-rank
#' --show-name --data-dir=path/to/downloaded/files | taxonkit reformat --data-dir=path/to/downloaded/files > All.lineages.tsv`
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
  if (file.exists(tf)) {
    message("NCBI taxonomic data has been downloaded.")
  }
  files <- utils::unzip(tf, files = c("names.dmp","nodes.dmp","delnodes.dmp", "merged.dmp"), exdir = td )
  if (!is.na(taxonkitpath)) { tryCatch(
      expr = {
        system(paste0("cd ", td,";",taxonkitpath," --data-dir=",
                      file.path(td) ," list --ids 1 | ",taxonkitpath ,
                      " lineage --show-lineage-taxids --show-lineage-ranks --show-rank --show-name --data-dir=",
                      file.path(td) ," | ",taxonkitpath ," reformat --data-dir=",
                      file.path(td) ," > All.lineages.tsv"), ignore.stderr = TRUE)
        unlink(tf)
        message("NCBI files parsed and result saved.")
        location <- file.path(td, "All.lineages.tsv")
        if (file.exists(location)&file.size(location)!=0) {
        message("NOTE: All.lineages.tsv is stored at ", td)
        location
        }
        else if (!file.exists(location)) {
          stop("Error saving All.lineages.tsv. Consider raising an issue on Github.")
        }
        else if (file.size(location)==0) {
          stop("All.lineages.tsv is empty. Consider raising an issue on Github.")
        }
      },
      warning = function(e){
        message("Double check the directory name you supplied and/or your write permissions!")
      })
  }
    else {
      unlink(tf)
      message("NOTE: NCBI .dmp files saved at ", td)
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
  if (file.exists(tf)) {
    message("GBIF backbone taxonomy has been downloaded.")
  }
  files <- utils::unzip(tf, files = c(file.path("backbone","Taxon.tsv")), exdir = td)
  if (file.exists(file.path(td, "backbone","Taxon.tsv"))) {
    message("Taxon.tsv has been extracted.")
    message("NOTE: Taxon.tsv is stored at ", files)
    unlink(tf)
    files
  }
  else if (!file.exists(file.path(td, "backbone","Taxon.tsv"))) {
    stop("Error saving Taxon.tsv. Consider raising an issue on Github.")
  }
}
