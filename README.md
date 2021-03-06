
# taxonbridge
<img src="https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_logo.png" align="left" style="margin: 0px 10px 0px 0px;" alt="" width="120"></img>
<!-- badges: start -->
[![R-CMD-check](https://github.com/MoultDB/taxonbridge/actions/workflows/main.yml/badge.svg)](https://github.com/MoultDB/taxonbridge/actions/workflows/main.yml)
[![badge](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/Werner0/a32a60e64ce4c19b9b63d9025b26c9d5/raw/dev_version.json)](https://github.com/MoultDB/taxonbridge#development-version)
[![CRAN Status](https://www.r-pkg.org/badges/version/taxonbridge)](https://CRAN.R-project.org/package=taxonbridge)
[![CRAN Downloads](https://cranlogs.r-pkg.org/badges/grand-total/taxonbridge)](https://cran.r-project.org/package=taxonbridge)
<!-- badges: end -->

Biological taxonomies establish conventions by which researchers can catalogue and systematically compare their work using nomenclature such as numeric identifiers and binomial names. The ideal taxonomy is unambiguous and exhaustive; however, no perfect taxonomy exists. The degree to which a taxonomy is useful to a researcher depends on context provided by, for example, the taxonomic neighborhood of a species or the geological timeframe of the study. Collating the most relevant taxonomic information from multiple taxonomies is hampered by arbitrary assignment of numeric identifiers by database administrators, ambiguity in scientific names, and duplication. The NCBI is the go-to resource for many scientists, but its taxonomy only includes data on species with sequence data. In contrast, the Global Biodiversity Information Facility (GBIF) backbone taxonomy references a more extensive list of extinct and extant species, and it is integrated with 100 other taxonomic databases. Unfortunately, the GBIF backbone taxonomy excludes the NCBI taxonomy. Since the NCBI and GBIF use different numeric identifiers, it is easy to imagine how using scientific names could lead to errors when mapping from one taxonomy to the other. As a case in point, additional lineage information could be used to validate mapping by recursively comparing parental taxon names. The goal of `taxonbridge` is hence to provide a set of tools for merging the GBIF backbone and NCBI taxonomies in order to derive a consistent, deduplicated and disambiguated custom taxonomy for any given study. See the [data provenance flow diagram](https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_data_provenance.pdf) and [scientific poster](https://github.com/MoultDB/taxonbridge/blob/master/poster.pdf) for more details.

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

See the `taxonbridge` [documentation](https://rdocumentation.org/packages/taxonbridge/) for detailed descriptions of the available methods and see the [workflow](https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_workflow.pdf) for how to use the methods. Custom taxonomies in `taxonbridge` always have the following 29 columns. All columns have the character data type. Column names with links are GBIF column names that are also [Darwin Core controlled vocabulary terms](https://dwc.tdwg.org).

Column name  		 	| Description
-----------------------	| -------------
[taxonID](https://dwc.tdwg.org/terms/)				 	| GBIF identifier
canonicalName		 	| GBIF/NCBI scientific name 
[taxonRank](https://dwc.tdwg.org/terms/)			 	| GBIF rank
[parentNameUsageID](https://dwc.tdwg.org/terms/)	 	| GBIF parent ID
[acceptedNameUsageID](https://dwc.tdwg.org/terms/)	 	| GBIF accepted ID
[originalNameUsageID](https://dwc.tdwg.org/terms/)	 	| GBIF original ID
[taxonomicStatus](https://dwc.tdwg.org/terms/)		 	| GBIF taxonomic status
[kingdom](https://dwc.tdwg.org/terms/)  			 	| GBIF kingdom name
[phylum](https://dwc.tdwg.org/terms/)  			 	| GBIF phylum name
[class](https://dwc.tdwg.org/terms/)  				 	| GBIF class name
[order](https://dwc.tdwg.org/terms/) 				 	| GBIF order name
[family](https://dwc.tdwg.org/terms/)  			 	| GBIF family name
[genericName](https://dwc.tdwg.org/terms/)  		 	| GBIF genus name
[specificEpithet](https://dwc.tdwg.org/terms/) 	    | GBIF species name
[infraspecificEpithet](https://dwc.tdwg.org/terms/)	| GBIF subspecies name	
from_GBIF 			 	| GBIF provenance indicator	
ncbi_id  				| NCBI identifier			
ncbi_lineage_names 		| NCBI full lineage names
ncbi_lineage_ids		| NCBI full lineage IDs
ncbi_rank  				| NCBI rank
ncbi_lineage_ranks		| NCBI full lineage ranks
ncbi_kingdom			| NCBI kingdom name
ncbi_phylum				| NCBI phylum name
ncbi_class				| NCBI class name
ncbi_order				| NCBI order name
ncbi_family				| NCBI family name
ncbi_genus				| NCBI genus name
ncbi_species			| NCBI species name
from_NCBI				| NCBI provenance indicator

## Examples

A 2000 row example subset of a previously merged taxonomy is bundled with `taxonbridge` and can be loaded as follow:

``` r
library(taxonbridge)
example_1 <- load_sample()
```

Want to try more than a sample? [Download](https://drive.google.com/file/d/1gpvm9QKdOcuGo_cIXPkAgGlB-qfKZZU6/view?usp=sharing) a larger dataset and load it as follow:

``` r
library(taxonbridge)
example_2 <- load_population("path/to/downloaded/dataset")
```
You can also prepare a dataset yourself which requires the use of external data and software. The most current NCBI and GBIF taxonomic data can be downloaded as follow:

``` r
download_gbif()
download_ncbi()
```

Once the downloads are complete, the paths to the downloaded files will be reported to your terminal. A single file is downloaded from the GBIF (`Taxon.tsv`) while four files are downloaded from the NCBI (`nodes.dmp`, `names.dmp`, `delnodes.dmp` and `merged.dmp`). Take note of the location of these files. The NCBI files require further parsing with [Taxonkit](https://bioinf.shenwei.me/taxonkit/download/). Read the `download_ncbi()` [documentation](https://rdocumentation.org/packages/taxonbridge/) for instructions on how to parse the NCBI files.

Downloading the GBIF and NCBI taxonomic data, parsing the NCBI files, and merging the taxonomies can easily be carried out in one command if [Taxonkit](https://bioinf.shenwei.me/taxonkit/download/) is already installed on your system: 
``` r
library(taxonbridge)
custom_taxonomy <- load_taxonomies(download_gbif(), download_ncbi(taxonkitpath = "/path/to/taxonkit"))
```

See the [workflow](https://github.com/MoultDB/taxonbridge/blob/master/taxonbridge_workflow.pdf) and [vignette](https://CRAN.R-project.org/package=taxonbridge) for more ideas on what to do with loaded data in `taxonbridge`.

## References

[Global Biodiversity Information Facility (GBIF) backbone taxonomy](https://hosted-datasets.gbif.org/datasets/backbone/current/)

[National Center for Biotechnology Information (NCBI) taxonomy](https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/)

## Citation

To cite `taxonbridge` in publications use:

Veldsman WP, Campli G, Dind S, Rech de Laval V, Drage HB, Waterhouse RM and Robinson-Rechavi M (2022) Taxonbridge: an R package to create custom taxonomies based on the NCBI and GBIF taxonomies, <i>bioRxiv</i>, <b>490269</b>. DOI: https://doi.org/10.1101/2022.05.02.490269
