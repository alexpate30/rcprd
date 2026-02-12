# Combine a CPRD aurum database query with a cohort.

An S3 method that can be used on database queries from Aurum extracts.
Combine a database query with a cohort, only retaining observations
between `time_prev` days prior to `indexdt`, and `time_post` days after
`indexdt`, and for test data with values between `lower_bound` and
`upper_bound`. The most recent `numobs` observations will be returned.
`cohort` must contain variables `patid` and `indexdt`. The `type` of
query must be specified for appropriate data manipulation. Input
`type = med` if interested in medical diagnoses from the observation
file, and `type = test` if interseted in test data from the observation
file.

## Usage

``` r
# S3 method for class 'aurum'
combine_query(
  db_query,
  cohort,
  query_type,
  time_prev = Inf,
  time_post = Inf,
  lower_bound = -Inf,
  upper_bound = Inf,
  numobs = 1,
  value_na_rm = TRUE,
  earliest_values = FALSE,
  reduce_output = FALSE
)
```

## Arguments

- db_query:

  Output from database query (ideally obtained through
  [`db_query`](https://alexpate30.github.io/rcprd/reference/db_query.md)).

- cohort:

  Cohort to combine with the database query.

- query_type:

  Type of query

- time_prev:

  Number of days prior to index date to look for codes.

- time_post:

  Number of days after index date to look for codes.

- lower_bound:

  Lower bound for returned values when `query_type = "test"`.

- upper_bound:

  Upper bound for returned values when `query_type = "test"`.

- numobs:

  Number of observations to be returned.

- value_na_rm:

  If TRUE will remove data with NA in the `value` column of the queried
  data and remove values outside of `lower_bound` and `upper_bound` when
  `query_type = "test"`.

- earliest_values:

  If TRUE will return the earliest values as opposed to most recent.

- reduce_output:

  If TRUE will reduce output to just `patid`, event date,
  medical/product code, and test `value`.

## Value

A data.table with observations that meet specified criteria.

## Details

`value_na_rm = FALSE` may be of use when extracting variables like
smoking status, where we want test data for number of cigarettes per
day, but do not want to remove all observations with NA in the `value`
column, because the medcodeid itself may indicate smoking status.

## Examples

``` r
## Create connection to a temporary database
aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

## Add observation data from all observation files in specified directory
cprd_extract(db = aurum_extract,
filepath = system.file("aurum_data", package = "rcprd"),
filetype = "observation")
#>   |                                                                              |                                                                      |   0%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_001.txt 2026-02-12 15:57:54.463654
#>   |                                                                              |=======================                                               |  33%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_002.txt 2026-02-12 15:57:54.477902
#>   |                                                                              |===============================================                       |  67%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_003.txt 2026-02-12 15:57:54.494578
#>   |                                                                              |======================================================================| 100%

## Query database for a specific medcode
db_query <- db_query(db_open = aurum_extract,
tab ="observation",
codelist_vector = "187341000000114")

## Define cohort
pat<-extract_cohort(filepath = system.file("aurum_data", package = "rcprd"))

### Add an index date to pat
pat$indexdt <- as.Date("01/01/2020", format = "%d/%m/%Y")

## Combine query with cohort retaining most recent three records
combine_query(cohort = pat,
db_query = db_query,
query_type = "med",
numobs = 3)
#>     patid pracid.x usualgpstaffid gender   yob   mob emis_ddate regstartdate
#>    <char>    <int>         <char>  <int> <int> <int>     <Date>       <Date>
#> 1:      2       79             11      1  1932    NA 1979-02-14   1929-02-23
#> 2:      6       54             11      1  1914    NA 1926-09-09   1970-08-28
#>    patienttypeid regenddate acceptable cprd_ddate    indexdt consid pracid.y
#>            <int>     <Date>      <int>     <Date>     <Date> <char>    <int>
#> 1:            21 1945-03-19          0 1932-02-05 2020-01-01     56        1
#> 2:            85 1983-03-14          1 1963-08-27 2020-01-01     40        1
#>     obsid    obsdate  enterdate staffid parentobsid       medcodeid value
#>    <char>     <Date>     <Date>  <char>      <char>          <char> <num>
#> 1:     77 1954-03-17 1932-02-22      24           4 187341000000114    46
#> 2:     41 1929-09-06 1951-01-12      98          80 187341000000114    28
#>    numunitid obstypeid numrangelow numrangehigh probobsid
#>        <int>     <int>       <num>        <num>    <char>
#> 1:        92        81          56           30        18
#> 2:        20         5          41           97        92

## clean up
RSQLite::dbDisconnect(aurum_extract)
unlink(file.path(tempdir(), "temp.sqlite"))
```
