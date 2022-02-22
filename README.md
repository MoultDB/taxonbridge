
# taxonbridge
<img src="https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_logo.png" align="left" style="margin: 0px 10px 0px 0px;" alt="" width="120"></img>
<!-- badges: start -->
[![R-CMD-check](https://github.com/MoultDB/taxonbridge/actions/workflows/main.yml/badge.svg)](https://github.com/MoultDB/taxonbridge/actions/workflows/main.yml)
[![CRAN Status](https://www.r-pkg.org/badges/version/taxonbridge)](https://CRAN.R-project.org/package=taxonbridge)
[![CRAN Downloads](https://cranlogs.r-pkg.org/badges/grand-total/taxonbridge)](https://cran.r-project.org/package=taxonbridge)
<!-- badges: end -->

Biological taxonomies establish conventions by which researchers can catalogue and systematically compare their work using nomenclature such as numeric identifiers and binomial names. The ideal taxonomy is unambiguous and exhaustive; however, no perfect taxonomy exists. The degree to which a taxonomy is useful to a researcher depends on context provided by, for example, the taxonomic neighborhood of a species or the geological timeframe of the study. Collating the most relevant taxonomic information from multiple taxonomies is hampered by arbitrary assignment of numeric identifiers by database administrators, ambiguity in scientific names, and duplication. The NCBI is the go-to resource for many scientists, but its taxonomy only includes data on species with sequence data. In contrast, the Global Biodiversity Information Facility (GBIF) backbone taxonomy references a more extensive list of extinct and extant species, and it is integrated with 100 other taxonomic databases. Unfortunately, the GBIF backbone taxonomy excludes the NCBI taxonomy. Since the NCBI and GBIF use different numeric identifiers, it is easy to imagine how using scientific names could lead to errors when mapping from one taxonomy to the other. As a case in point, additional lineage information could be used to validate mapping by recursively comparing parental taxon names. The goal of `taxonbridge` is hence to provide a set of tools for merging the GBIF backbone and NCBI taxonomies in order to derive a consistent, deduplicated and disambiguated custom taxonomy for any given study (see [data provenance](https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_data_provenance.pdf)).

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
install.packages(c("devtools", "rmarkdown"))
devtools::install_github("MoultDB/taxonbridge", build_vignettes = TRUE)
library(taxonbridge)
```

`taxonbridge` can be also be updated/re-installed/overwritten with either of the preceding installation options. 

## Available methods and how to use them

See the `taxonbridge` [documentation]( https://rdocumentation.org/packages/taxonbridge/versions/1.0.1) and [workflow](https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_workflow.pdf).

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

[Global Biodiversity Information Facility (GBIF) backbone taxonomy](https://hosted-datasets.gbif.org/datasets/backbone/current/) (use `download_gbif()` and note the location of the file Taxon.tsv).

[National Centre for Biotechnology Information (NCBI) taxonomy](https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/) (use `download_ncbi()` and parse the downloaded files with [Taxonkit](https://bioinf.shenwei.me/taxonkit/download/) according to its guidelines, or use `download_ncbi(taxonkitpath = "/path/to/taxonkit")` to carry
out parsing automatically if Taxonkit is installed on your system):

``` r
library(taxonbridge)
custom_taxonomy <- load_taxonomies(download_gbif(), download_ncbi(taxonkitpath = "/path/to/taxonkit"))
```

Read the `load_taxonomies()` function [documentation](https://rdocumentation.org/packages/taxonbridge/versions/1.0.1/topics/load_taxonomies) for instructions on how to load a dataset of your own.

See the [workflow](https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_workflow.pdf) and [vignette](https://CRAN.R-project.org/package=taxonbridge) for more ideas on what to do with loaded data in `taxonbridge`.
