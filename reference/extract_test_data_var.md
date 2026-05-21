# Extract standard deviation of all test data values over a specified time period relative to an index date.

Extract standard deviation of all test data values over a specified time
period relative to an index date.

## Usage

``` r
extract_test_data_var(
  cohort,
  varname = NULL,
  codelist = NULL,
  codelist_vector = NULL,
  codelist_df = NULL,
  indexdt,
  t = NULL,
  t_varname = TRUE,
  time_prev = 365.25 * 5,
  time_post = 0,
  lower_bound = -Inf,
  upper_bound = Inf,
  db_open = NULL,
  db = NULL,
  db_filepath = NULL,
  table_name = NULL,
  out_save_disk = FALSE,
  out_subdir = NULL,
  out_filepath = NULL,
  return_output = FALSE
)
```

## Arguments

- cohort:

  Cohort of individuals to extract the 'history of' variable for.

- varname:

  Name of variable in the outputted data frame.

- codelist:

  Name of codelist (stored on hard disk) to query the database with.

- codelist_vector:

  Vector of codes to query the database with. This takes precedent over
  `codelist` if both are specified.

- codelist_df:

  data.frame used to specify the codelist.

- indexdt:

  Name of variable in `cohort` which specifies the index date. The
  extracted variable will be calculated relative to this.

- t:

  Number of days after `indexdt` at which to extract the variable.

- t_varname:

  Whether to alter the variable name in the outputted data frame to
  reflect `t`.

- time_prev:

  Number of days prior to index date to look for codes.

- time_post:

  Number of days after index date to look for codes.

- lower_bound:

  Lower bound for returned values.

- upper_bound:

  Upper bound for returned values.

- db_open:

  An open SQLite database connection created using RSQLite::dbConnect,
  to be queried.

- db:

  Name of SQLITE database on hard disk (stored in "data/sql/"), to be
  queried.

- db_filepath:

  Full filepath to SQLITE database on hard disk, to be queried.

- table_name:

  Specify name of table in the SQLite database to be queried, if this is
  different from 'observation'.

- out_save_disk:

  If `TRUE` will attempt to save outputted data frame to directory
  "data/extraction/".

- out_subdir:

  Sub-directory of "data/extraction/" to save outputted data frame into.

- out_filepath:

  Full filepath and filename to save outputted data frame into.

- return_output:

  If `TRUE` will return outputted data frame into R workspace.

## Value

A data frame containing standard deviation of test results.

## Details

Specifying `db` requires a specific underlying directory structure. The
SQLite database must be stored in "data/sql/" relative to the working
directory. If the SQLite database is accessed through `db`, the
connection will be opened and then closed after the query is complete.
The same is true if the database is accessed through `db_filepath`. A
connection to the SQLite database can also be opened manually using
`RSQLite::dbConnect`, and then using the object as input to parameter
`db_open`. After wards, the connection must be closed manually using
`RSQLite::dbDisconnect`. If `db_open` is specified, this will take
precedence over `db` or `db_filepath`.

If `out_save_disk = TRUE`, the data frame will automatically be written
to an .rds file in a subdirectory "data/extraction/" of the working
directory. This directory structure must be created in advance.
`out_subdir` can be used to specify subdirectories within
"data/extraction/". These options will use a default naming convetion.
This can be overwritten using `out_filepath` to manually specify the
location on the hard disk to save. Alternatively, return the data frame
into the R workspace using `return_output = TRUE` and then save onto the
hard disk manually.

Currently only returns most recent test result. This will be updated to
return more than one most recent test result if specified.

The argument `table_name` is only necessary if the name of the table
being queried does not match 'observation'. This will occur when
`str_match` is used in `cprd_extract` or `add_to_database` to create the
.sqlite database.

## Examples

``` r

## Connect
aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

## Create SQLite database using cprd_extract
cprd_extract(aurum_extract,
filepath = system.file("aurum_data", package = "rcprd"),
filetype = "observation", use_set = FALSE)
#>   |                                                                              |                                                                      |   0%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_001.txt 2026-05-21 21:16:37.177657
#>   |                                                                              |=======================                                               |  33%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_002.txt 2026-05-21 21:16:37.191199
#>   |                                                                              |===============================================                       |  67%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_003.txt 2026-05-21 21:16:37.202792
#>   |                                                                              |======================================================================| 100%

## Define cohort and add index date
pat<-extract_cohort(system.file("aurum_data", package = "rcprd"))
pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")

## Extract standard deviation of previous test scores prior to index date
extract_test_data_var(pat,
codelist_vector = "187341000000114",
indexdt = "fup_start",
db_open = aurum_extract,
time_prev = Inf,
return_output = TRUE)
#>    patid value_var
#> 1      1        NA
#> 2     10        NA
#> 3     11        NA
#> 4     12        NA
#> 5      2        NA
#> 6      3        NA
#> 7      4        NA
#> 8      5        NA
#> 9      6        NA
#> 10     7        NA
#> 11     8        NA
#> 12     9        NA

## clean up
RSQLite::dbDisconnect(aurum_extract)
unlink(file.path(tempdir(), "temp.sqlite"))
```
