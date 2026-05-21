# Combine practice files

Combine practice files

## Usage

``` r
extract_practices(filepath, select = NULL)
```

## Arguments

- filepath:

  Path to directory containing practice .txt files.

- select:

  Character vector of column names to select.

## Value

Data frame with patient information

## Examples

``` r

## Extract cohort data
prac<-extract_practices(filepath = system.file("aurum_data", package = "rcprd"))
prac
#>   pracid        lcd  uts region
#> 1     49 1941-09-20 <NA>     48
#> 2     53 1978-01-31 <NA>     51
#> 3     54 1948-10-01 <NA>     54
#> 4     62 1905-03-11 <NA>      9
#> 5     79 1969-06-25 <NA>      7
#> 6     98 1992-05-10 <NA>     48
```
