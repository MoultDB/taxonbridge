% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helper_methods.R
\name{annotate}
\alias{annotate}
\title{Annotate a custom taxonomy}
\usage{
annotate(x, names, new_column, present = "1", absent = NA)
}
\arguments{
\item{x}{A tibble with taxonomic data to be annotated.}

\item{names}{A character vector containing scientific names that will be matched to scientific names in \code{x}.}

\item{new_column}{A string to be the name of a new column that will contain annotations.}

\item{present}{A string with the annotation in the case of a match (Defaults to "1").}

\item{absent}{A string with the annotation in case of no match (Defaults to NA).}
}
\value{
A tibble that contains an additional column with annotations.
}
\description{
Annotate a custom taxonomy
}
\details{
This method takes as input a character vector with scientific names. If the
scientific name(s) in the vector match with scientific names in the tibble, a new
column will be created and an annotation of choice will be added to the relevant row
in the new column. This method is useful for annotating scientific names with identified
ambiguity, duplication or any other characteristic. The character vector could, for example,
even contain scientific names that have not been derived with a Taxonbridge method.
}
\examples{
sample <- load_sample()
lineages <- get_lineages(sample)
kingdom <- get_validity(lineages, rank = "kingdom", valid = FALSE)
family <- get_validity(lineages, rank = "family", valid = FALSE)
candidates <- list(kingdom, family)
binomials <- get_inconsistencies(candidates, uninomials = FALSE, set = "intersect")
x <- annotate(sample, binomials, new_column = "inconsistencies", "Accepted but ambigious")
x[!is.na(x$inconsistencies),c("inconsistencies")]
}
