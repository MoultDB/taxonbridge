
# moultdbtools

<!-- badges: start -->
<!-- badges: end -->

There are three main sources of taxonomic information on the internet: The Global Biodiversity Information Facility (GBIF), the National Centre for Biotechnology Information (NCBI), and the Catalogue of Life (COL). The NCBI is the go to resource for many scientists, but it only includes data on extant species. The GBIF includes extant species and it has integrated the COL into its taxonomic database (i.e. the GBIF backbone taxonomy). However, he NCBI taxonomy is not integrated into the GBIF backbone taxonomy. The goal of `moultdbtools` is to provide tools for merging the GBIF backbone taxonomy and the NCBI taxonomy. 

## Installation

You can install the development version of `moultdbtools` by cloning this repository and executing the following command from within R:

``` r
install.packages("path/to/moultdbtools_0.0.0.9000.tar.gz", repos = NULL, type="source")
library(mouldtdbtools)
```

OR download `mouldbtools` directly from Github without cloning the repository:

``` r
install.packages("devtools")
library(devtools)
install_github("MoultDB/moultdbtools")
library(moultdbtools)
```

## Available methods and how to use them:

See the `moultdbtools` [documentation](https://github.com/MoultDB/moultdbtools/blob/master/moultdbtools_0.0.0.9000.pdf) and [workflow](https://github.com/MoultDB/moultdbtools/blob/master/moultdbtools_workflow.pdf).

## Example

This is a basic example which uses a function from each of the `moultdbtools` package's four main function categories:

``` r
library(moultdbtools)
plot_mdb(prepare_comparable_rank_dist(get_validity(get_status(load_sample()), valid = TRUE)))
```

