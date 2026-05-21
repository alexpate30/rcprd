# Extract smoking status prior to index date.

Extract smoking status prior to index date.

## Usage

``` r
extract_smoking(
  cohort,
  varname = NULL,
  codelist_non = NULL,
  codelist_ex = NULL,
  codelist_light = NULL,
  codelist_mod = NULL,
  codelist_heavy = NULL,
  codelist_non_vector = NULL,
  codelist_ex_vector = NULL,
  codelist_light_vector = NULL,
  codelist_mod_vector = NULL,
  codelist_heavy_vector = NULL,
  codelist_non_df = NULL,
  codelist_ex_df = NULL,
  codelist_light_df = NULL,
  codelist_mod_df = NULL,
  codelist_heavy_df = NULL,
  indexdt,
  t = NULL,
  t_varname = TRUE,
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

- codelist_non:

  Name of codelist (stored on hard disk in "codelists/analysis/") for
  non-smoker to query the database with.

- codelist_ex:

  Name of codelist (stored on hard disk in "codelists/analysis/") for
  ex-smoker to query the database with.

- codelist_light:

  Name of codelist (stored on hard disk in "codelists/analysis/") for
  light smoker to query the database with.

- codelist_mod:

  Name of codelist (stored on hard disk in "codelists/analysis/") for
  moderate smoker to query the database with.

- codelist_heavy:

  Name of codelist (stored on hard disk in "codelists/analysis/") for
  heavy smoker to query the database with.

- codelist_non_vector:

  Vector of codes for non-smoker to query the database with.

- codelist_ex_vector:

  Vector of codes for ex-smoker to query the database with.

- codelist_light_vector:

  Vector of codes for light smoker to query the database with.

- codelist_mod_vector:

  Vector of codes for moderate smoker to query the database with.

- codelist_heavy_vector:

  Vector of codes for heavy smoker to query the database with.

- codelist_non_df:

  data.frame of codes for non-smoker to query the database with.

- codelist_ex_df:

  data.frame of codes for ex-smoker to query the database with.

- codelist_light_df:

  data.frame of codes for light smoker to query the database with.

- codelist_mod_df:

  data.frame of codes for moderate smoker to query the database with.

- codelist_heavy_df:

  data.frame of codes for heavy smoker to query the database with.

- indexdt:

  Name of variable which defines index date in `cohort`.

- t:

  Number of days after index date at which to calculate variable.

- t_varname:

  Whether to add `t` to `varname`.

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

A data frame with variable smoking status.

## Details

Returns the most recent value of smoking status. If the most recently
recorded observation of smoking status is non-smoker, but the individual
has a history of smoking identified through the medical record, the
outputted value of smoking status will be ex-smoker. Full details on the
algorithm for extracting smoking status are given in the vignette:
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

We take the most recent smoking status record. If an individuals most
recent smoking status is a non-smoker, but they have a history of
smoking prior to this, these individuals will be classed as ex-smokers.

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
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_001.txt 2026-05-21 21:16:36.603242
#>   |                                                                              |=======================                                               |  33%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_002.txt 2026-05-21 21:16:36.619725
#>   |                                                                              |===============================================                       |  67%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_003.txt 2026-05-21 21:16:36.63066
#>   |                                                                              |======================================================================| 100%

## Define cohort and add index date
pat<-extract_cohort(system.file("aurum_data", package = "rcprd"))
pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")

## Extract smoking status prior to index date
extract_smoking(cohort = pat,
codelist_non_vector = "498521000006119",
codelist_ex_vector = "401539014",
codelist_light_vector = "128011000000115",
codelist_mod_vector = "380389013",
codelist_heavy_vector = "13483031000006114",
indexdt = "indexdt",
db_open = aurum_extract)
#>    patid   smoking
#> 1      1      <NA>
#> 2     10      <NA>
#> 3     11      <NA>
#> 4     12      <NA>
#> 5      2      <NA>
#> 6      3      <NA>
#> 7      4     Heavy
#> 8      5 Ex-smoker
#> 9      6  Moderate
#> 10     7      <NA>
#> 11     8      <NA>
#> 12     9      <NA>

## clean up
RSQLite::dbDisconnect(aurum_extract)
unlink(file.path(tempdir(), "temp.sqlite"))
```
