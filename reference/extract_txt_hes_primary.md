# Read in raw HES primary diagnoses file

Read in raw HES primary diagnoses file

## Usage

``` r
extract_txt_hes_primary(filepath, ..., select = NULL)
```

## Arguments

- filepath:

  File path to raw .txt file

- ...:

  Arguments to pass onto data.table::fread

- select:

  Character vector of variable names to select
