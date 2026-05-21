# Extract diabetes status prior to an index date.

Extract diabetes status prior to an index date.

## Usage

``` r
extract_diabetes(
  cohort,
  varname = NULL,
  codelist_type1 = NULL,
  codelist_type2 = NULL,
  codelist_type1_vector = NULL,
  codelist_type2_vector = NULL,
  codelist_type1_df = NULL,
  codelist_type2_df = NULL,
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

- codelist_type1:

  Name of codelist (stored on hard disk in "codelists/analysis/") for
  type 1 diabetes to query the database with.

- codelist_type2:

  Name of codelist (stored on hard disk in "codelists/analysis/") for
  type 2 diabetes to query the database with.

- codelist_type1_vector:

  Vector of codes for type 1 diabetes to query the database with.

- codelist_type2_vector:

  Vector of codes for type 2 diabetes to query the database with.

- codelist_type1_df:

  data.frame of codes for type 1 diabetes to query the database with.

- codelist_type2_df:

  data.frame of codes for type 2 diabetes to query the database with.

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

A data frame with variable diabetes status.

## Details

If an individual is found to have medical codes for both type 1 and type
2 diabetes, the returned value of diabetes status will be type 1
diabetes. Full details on the algorithm for extracting diabetes status
are given in the vignette:
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
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_001.txt 2026-05-21 21:16:35.998334
#>   |                                                                              |=======================                                               |  33%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_002.txt 2026-05-21 21:16:36.011159
#>   |                                                                              |===============================================                       |  67%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_003.txt 2026-05-21 21:16:36.022086
#>   |                                                                              |======================================================================| 100%

## Define cohort and add index date
pat<-extract_cohort(system.file("aurum_data", package = "rcprd"))
pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")

## Extract diabetes prior to index date
extract_diabetes(cohort = pat,
codelist_type1_vector = "498521000006119",
codelist_type2_vector = "401539014",
indexdt = "indexdt",
db_open = aurum_extract)
#>    patid diabetes
#> 1      1   Absent
#> 2      2   Absent
#> 3      3   Absent
#> 4      4   Absent
#> 5      5    Type1
#> 6      6   Absent
#> 7      7   Absent
#> 8      8   Absent
#> 9      9   Absent
#> 10    10   Absent
#> 11    11   Absent
#> 12    12   Absent

## clean up
RSQLite::dbDisconnect(aurum_extract)
unlink(file.path(tempdir(), "temp.sqlite"))
```
