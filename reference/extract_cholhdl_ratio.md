# Extract most recent total cholesterol/high-density lipoprotein ratio score relative to an index date.

Extract most recent total cholesterol/high-density lipoprotein ratio
score relative to an index date.

## Usage

``` r
extract_cholhdl_ratio(
  cohort,
  varname = NULL,
  codelist_ratio = NULL,
  codelist_chol = NULL,
  codelist_hdl = NULL,
  codelist_ratio_vector = NULL,
  codelist_chol_vector = NULL,
  codelist_hdl_vector = NULL,
  codelist_ratio_df = NULL,
  codelist_chol_df = NULL,
  codelist_hdl_df = NULL,
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
  return_output = TRUE
)
```

## Arguments

- cohort:

  Cohort to extract age for.

- varname:

  Optional name for variable in output dataset.

- codelist_ratio:

  Name of codelist (stored on hard disk in "codelists/analysis/") for
  ratio to query the database with.

- codelist_chol:

  Name of codelist (stored on hard disk in "codelists/analysis/") for
  total cholesterol to query the database with.

- codelist_hdl:

  Name of codelist (stored on hard disk in "codelists/analysis/") for
  high-density lipoprotein to query the database with.

- codelist_ratio_vector:

  Vector of codes for ratio to query the database with.

- codelist_chol_vector:

  Vector of codes for total cholesterol to query the database with.

- codelist_hdl_vector:

  Vector of codes for high-density lipoprotein to query the database
  with.

- codelist_ratio_df:

  data.frame of codes for ratio to query the database with.

- codelist_chol_df:

  data.frame of codes for total cholesterol to query the database with.

- codelist_hdl_df:

  data.frame of codes for high-density lipoprotein to query the database
  with.

- indexdt:

  Name of variable which defines index date in `cohort`.

- t:

  Number of days after index date at which to calculate variable.

- t_varname:

  Whether to add `t` to `varname`.

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

A data frame with variable total cholesterol/high-density lipoprotein
ratio.

## Details

Cholesterol/HDL ratio can either be identified through a directly
recorded cholesterol/hdl ratio score, or calculated via total
cholesterol and HDL scores. Full details on the algorithm for extracting
cholesterol/hdl ratio are given in the vignette:
Details-on-algorithms-for-extracting-specific-variables. This vignette
can be viewed by running `vignette("help", package = "rcprd")`.

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

Specifying the non-vector type codelists requires a specific underlying
directory structure. The codelist on the hard disk must be stored in
"codelists/analysis/" relative to the working directory, must be a .csv
file, and contain a column "medcodeid", "prodcodeid" or "ICD10"
depending on the chosen `tab`. The input to these variables should just
be the name of the files (excluding the suffix .csv). The codelists can
also be read in manually, and supplied as a character vector. This
option will take precedence over the codelists stored on the hard disk
if both are specified.

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
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_001.txt 2026-02-12 15:57:56.742859
#>   |                                                                              |=======================                                               |  33%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_002.txt 2026-02-12 15:57:56.756418
#>   |                                                                              |===============================================                       |  67%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_003.txt 2026-02-12 15:57:56.773259
#>   |                                                                              |======================================================================| 100%

## Define cohort and add index date
pat<-extract_cohort(system.file("aurum_data", package = "rcprd"))
pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")

## Extract most recent cholhdl_ratio prior to index date
extract_cholhdl_ratio(cohort = pat,
codelist_ratio_vector = "498521000006119",
codelist_chol_vector = "401539014",
codelist_hdl_vector = "13483031000006114",
indexdt = "indexdt",
time_prev = Inf,
db_open = aurum_extract,
return_output = TRUE)
#>    patid cholhdl_ratio
#> 1      1            NA
#> 2     10            NA
#> 3     11            NA
#> 4     12            NA
#> 5      2            NA
#> 6      3            NA
#> 7      4            NA
#> 8      5            18
#> 9      6            NA
#> 10     7            NA
#> 11     8            NA
#> 12     9            NA

## clean up
RSQLite::dbDisconnect(aurum_extract)
unlink(file.path(tempdir(), "temp.sqlite"))
```
