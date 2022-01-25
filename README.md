
# taxonbridge
<img src="https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_logo.png" align="left" style="margin: 0px 10px 0px 0px;" alt="" width="120"></img>
<!-- badges: start -->
[![R-CMD-check](https://github.com/MoultDB/taxonbridge/actions/workflows/main.yml/badge.svg)](https://github.com/MoultDB/taxonbridge/actions/workflows/main.yml)
[![CRAN Status](https://www.r-pkg.org/badges/version/taxonbridge)](https://CRAN.R-project.org/package=taxonbridge)
[![CRAN Downloads](https://cranlogs.r-pkg.org/badges/grand-total/taxonbridge)](https://cran.r-project.org/package=taxonbridge)
<!-- badges: end -->

There are three main sources of taxonomic information on the internet: The Global Biodiversity Information Facility (GBIF), the National Centre for Biotechnology Information (NCBI), and the Catalogue of Life (COL). The NCBI is the go to resource for many scientists, but it only includes data on extant species. The GBIF includes extinct as well as extant species, and it has integrated the COL into its taxonomic database (i.e. the GBIF backbone taxonomy). However, the NCBI taxonomy is not integrated into the GBIF backbone taxonomy. The goal of `taxonbridge` is to provide tools for merging the GBIF backbone taxonomy and the NCBI taxonomy (see [data provenance](https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_data_provenance.pdf)).

## Installation

### CRAN version:

To install `taxonbridge` from CRAN type:

``` r
install.packages("taxonbridge")
library(taxonbridge)
```

Note that the version on CRAN might not reflect the most recent changes made to the development version of `taxonbridge`.

### Development version:

You can install the development version of `taxonbridge` with `devtools`:

``` r
install.packages("devtools")
library(devtools)
install_github("MoultDB/taxonbridge")
library(taxonbridge)
```

`taxonbridge` can be also be updated/re-installed/overwritten with either of the preceding installation options. 

## Available methods and how to use them

See the `taxonbridge` [documentation](https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_1.0.1.pdf) and [workflow](https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_workflow.pdf).

## Examples

This is a basic example which uses a function from each of the `taxonbridge` package's four main function categories to load and manipulate sample data:

``` r
library(taxonbridge)
plot_mdb(prepare_comparable_rank_dist(get_validity(get_status(load_sample()), valid = TRUE)))
```

Want to try more than a sample? [Download](https://drive.google.com/file/d/1gpvm9QKdOcuGo_cIXPkAgGlB-qfKZZU6/view?usp=sharing) a larger dataset and load it as follow:

``` r
library(taxonbridge)
load_population("path/to/downloaded/dataset")
```
You can also prepare a dataset yourself which requires the use of external data and software available at the following links:

[Global Biodiversity Information Facility (GBIF) backbone taxonomy](https://hosted-datasets.gbif.org/datasets/backbone/current/) (download backbone.zip)

[National Centre for Biotechnology Information (NCBI) taxonomy](https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/) (to be parsed with the [Taxonkit](https://bioinf.shenwei.me/taxonkit/download/) program according to its guidelines)

Next, read the `load_taxonomies()` [documentation](https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_1.0.1.pdf) for instructions on how to load a dataset of your own:

``` r
library(taxonbridge)
?load_taxonomies
```

See the [workflow](https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_workflow.pdf) for more ideas on what to do with loaded data in `taxonbridge`.
