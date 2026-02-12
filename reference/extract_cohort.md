# Create cohort from patient files

Create cohort from patient files

## Usage

``` r
extract_cohort(filepath, patids = NULL, select = NULL, set = FALSE)
```

## Arguments

- filepath:

  Path to directory containing patient .txt files.

- patids:

  Patids of patients to retain in the cohort. Character vector. Numeric
  values should not be used.

- select:

  Character vector of column names to select.

- set:

  If `TRUE` will create a variable called `set` which will contain the
  number that comes after the word 'set' in the file name.

## Value

Data frame with patient information

## Examples

``` r
## Extract cohort data
pat<-extract_cohort(filepath = system.file("aurum_data", package = "rcprd"))
pat
#>    patid pracid usualgpstaffid gender  yob mob emis_ddate regstartdate
#> 1      1     49              6      2 1984  NA 1976-11-21   1940-07-24
#> 2      2     79             11      1 1932  NA 1979-02-14   1929-02-23
#> 3      3     98             43      1 1930  NA 1972-06-01   1913-07-02
#> 4      4     53             72      2 1915  NA 1989-04-24   1969-07-11
#> 5      5     62             16      2 1916  NA 1951-09-23   1919-11-07
#> 6      6     54             11      1 1914  NA 1926-09-09   1970-08-28
#> 7      7     49              6      2 1984  NA 1976-11-21   1940-07-24
#> 8      8     79             11      1 1932  NA 1979-02-14   1929-02-23
#> 9      9     98             43      1 1930  NA 1972-06-01   1913-07-02
#> 10    10     53             72      2 1915  NA 1989-04-24   1969-07-11
#> 11    11     62             16      2 1916  NA 1951-09-23   1919-11-07
#> 12    12     54             11      1 1914  NA 1926-09-09   1970-08-28
#>    patienttypeid regenddate acceptable cprd_ddate
#> 1             58 1996-08-25          1 1935-03-17
#> 2             21 1945-03-19          0 1932-02-05
#> 3             81 1997-04-24          1 1912-04-27
#> 4             10 1951-09-05          0 1921-02-13
#> 5             45 1998-11-25          0 1903-08-26
#> 6             85 1983-03-14          1 1963-08-27
#> 7             58 1996-08-25          1 1935-03-17
#> 8             21 1945-03-19          0 1932-02-05
#> 9             81 1997-04-24          1 1912-04-27
#> 10            10 1951-09-05          0 1921-02-13
#> 11            45 1998-11-25          0 1903-08-26
#> 12            85 1983-03-14          1 1963-08-27
```
