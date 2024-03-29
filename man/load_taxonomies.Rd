% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load_methods.R
\name{load_taxonomies}
\alias{load_taxonomies}
\title{Load and merge GBIF and NCBI taxonomic data}
\usage{
load_taxonomies(GBIF_path, NCBI_path)
}
\arguments{
\item{GBIF_path}{Path to the GBIF backbone taxonomy (compressed or uncompressed).}

\item{NCBI_path}{Path to the NCBI taxonomy (compressed or uncompressed).}
}
\value{
A tibble containing merged GBIF and NCBI taxonomic data.
}
\description{
Load and merge GBIF and NCBI taxonomic data
}
\details{
This method merges a GBIF \code{Taxon.tsv} file (see \code{download_gbif()}) and
a Taxonkit (\url{https://bioinf.shenwei.me/taxonkit/download/}) output file (see \code{download_ncbi()}).
}
\examples{
\dontrun{load_taxonomies("path/to/GBIF/Taxon.tsv","path/to/NCBI-Taxonkit/All.lineages.tsv.gz")}
\dontrun{load_taxonomies(download_gbif(), download_ncbi(taxonkitpath = "/path/to/taxonkit"))}
}
