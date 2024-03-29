% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_methods.R
\name{get_lineages}
\alias{get_lineages}
\title{Get entries that have lineage information for both the GBIF and NCBI data}
\usage{
get_lineages(x)
}
\arguments{
\item{x}{A tibble created with \code{load_taxonomies()} or \code{load_population()} or \code{load_sample()}.}
}
\value{
A tibble with complete lineage data.
}
\description{
Get entries that have lineage information for both the GBIF and NCBI data
}
\examples{
get_lineages(load_sample())
}
