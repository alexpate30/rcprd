# Read in raw ONS death data file

Read in raw ONS death data file

## Usage

``` r
extract_txt_death(filepath, ..., select = NULL)
```

## Arguments

- filepath:

  File path to raw .txt file

- ...:

  Arguments to pass onto data.table::fread

- select:

  Character vector of variable names to select
