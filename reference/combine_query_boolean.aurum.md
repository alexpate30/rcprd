# Combine a CPRD aurum database query with a cohort returning a 0/1 vector depending on whether each individual has a recorded code of interest.

An S3 method that can be used on database queries from Aurum extracts.
Combine a database query with a cohort returning a 0/1 vector depending
on whether each individual has a recorded code of interest. `cohort`
must contain variables `patid` and `indexdt`. The database query will be
merged with the cohort by variable `patid`. If an individual has at
least `numobs` observations between `time_prev` days prior to `indexdt`,
and `time_post` days after `indexdt`, a 1 will be returned, 0 otherwise.
The `type` of query must be specified for appropriate data manipulation.

## Usage

``` r
# S3 method for class 'aurum'
combine_query_boolean(
  db_query,
  cohort,
  query_type,
  time_prev = Inf,
  time_post = 0,
  numobs = 1
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

- numobs:

  Number of observations required to be observed in specified time
  window to return a 1.

## Value

A 0/1 vector.

## Examples

``` r
## Create connection to a temporary database
aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

## Add observation data from all observation files in specified directory
cprd_extract(db = aurum_extract,
filepath = system.file("aurum_data", package = "rcprd"),
filetype = "observation")
#>   |                                                                              |                                                                      |   0%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_001.txt 2026-02-12 15:57:54.88352
#>   |                                                                              |=======================                                               |  33%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_002.txt 2026-02-12 15:57:54.898959
#>   |                                                                              |===============================================                       |  67%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_003.txt 2026-02-12 15:57:54.912479
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
combine_query_boolean(cohort = pat,
db_query = db_query,
query_type = "med",
numobs = 3)
#>  [1] 0 0 0 0 0 0 0 0 0 0 0 0

## clean up
RSQLite::dbDisconnect(aurum_extract)
unlink(file.path(tempdir(), "temp.sqlite"))
```
