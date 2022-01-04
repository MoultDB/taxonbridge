
# moultdbtools

<!-- badges: start -->
<!-- badges: end -->

There are three main sources of taxonomic information on the internet: The Global Biodiversity Information Facility (GBIF), the National Centre for Biotechnology Information (NCBI), and the Catalogue of Life (COL). The NCBI is the go to resource for many scientists, but it only includes data on extant species. The GBIF includes extinct as well as extant species, and it has integrated the COL into its taxonomic database (i.e. the GBIF backbone taxonomy). However, the NCBI taxonomy is not integrated into the GBIF backbone taxonomy. The goal of `moultdbtools` is to provide tools for merging the GBIF backbone taxonomy and the NCBI taxonomy. 

## Installation

You can install the development version of `moultdbtools` by cloning this repository and executing the following command from within R:

``` r
install.packages("path/to/moultdbtools_0.0.0.9000.tar.gz", repos = NULL, type="source")
library(moultdbtools)
```

OR download `moultdbtools` directly from Github without cloning the repository:

``` r
install.packages("devtools")
library(devtools)
install_github("MoultDB/moultdbtools")
library(moultdbtools)
```

## Available methods and how to use them

See the `moultdbtools` [documentation](https://github.com/MoultDB/moultdbtools/blob/master/moultdbtools_0.0.0.9000.pdf) and [workflow](https://github.com/MoultDB/moultdbtools/blob/master/moultdbtools_workflow.pdf).

## Examples

* This is a basic example which uses a function from each of the `moultdbtools` package's four main function categories to load and manipulate sample data:

``` r
library(moultdbtools)
plot_mdb(prepare_comparable_rank_dist(get_validity(get_status(load_sample()), valid = TRUE)))
```

* Want to try more than a sample? [Download](https://drive.google.com/file/d/1gpvm9QKdOcuGo_cIXPkAgGlB-qfKZZU6/view?usp=sharing) a larger dataset and load it as follow:

``` r
library(moultdbtools)
load_population("path/to/downloaded/dataset")
```
* You can also prepare a dataset yourself, which requires the use of external data and software available at the following links:

[Global Biodiversity Information Facility (GBIF) backbone taxonomy](https://hosted-datasets.gbif.org/datasets/backbone/current/) (download backbone.zip)

[National Centre for Biotechnology Information (NCBI) taxonomy](https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/) (to be parsed with the [Taxonkit](https://bioinf.shenwei.me/taxonkit/download/) program according to its guidelines)

Next, read the `load_taxonomies()` [documentation](https://github.com/MoultDB/moultdbtools/blob/master/moultdbtools_0.0.0.9000.pdf) for instructions on how to load a dataset of your own:

``` r
library(moultdbtools)
?load_taxonomies
```

See the [workflow](https://github.com/MoultDB/moultdbtools/blob/master/moultdbtools_workflow.pdf) for more ideas on what to do with loaded data in `moultdbtools`.
