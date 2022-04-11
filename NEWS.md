# taxonbridge 1.2.0

* Load methods now convert all columns to character data type
* Documentation updates

# taxonbridge 1.1.0

* New hexagonal logo and workflow
* Updated vignette
* Updated `fuzzy_search()` method with `force_binomial` parameter
* Additional NCBI columns in merged taxonomy [BREAKING CHANGE]
* Updated `get_taxa()` method

# taxonbridge 1.0.5

* Added `dedupe()` method

# taxonbridge 1.0.4

* Updated `get_validity()` method
* Fixed bug in `load_taxonomies()` when reading in GBIF data with vroom
* Updated vignette
* Added `annotate()` method

# taxonbridge 1.0.3

* Updated v1.0.2 documentation
* Added `fuzzy_search()` method
* Added `download_gbif()` method
* Added set operation parameter to `get_inconsistencies()`
* Fixed bug in `get_inconsistencies()` when uninomials are set to true
* Added `download_ncbi()` method

# taxonbridge 1.0.2

* Added `get_taxa()` method
* Added a vignette
* Added `get_inconsistencies()` method
* Added merge stats to `load_taxonomies()` output tibble attributes fields
* Added provenance columns to `load_taxonomies()` output tibble
* Fixed bug when loading stub data with `load_taxonomies()`
* Added `taxonbridge` logo
