# Extract a 'history of' type variable

Query an RSQLite database and return a data frame with a 0/1 vector
depending on whether each individual has at least one observation with
relevant code between a specified time period.

## Usage

``` r
extract_ho(
  cohort,
  varname = NULL,
  codelist = NULL,
  codelist_vector = NULL,
  codelist_df = NULL,
  indexdt,
  t = NULL,
  t_varname = TRUE,
  time_prev = Inf,
  time_post = 0,
  numobs = 1,
  db_open = NULL,
  db = NULL,
  db_filepath = NULL,
  tab = c("observation", "drugissue", "hes_primary", "death"),
  table_name = NULL,
  out_save_disk = FALSE,
  out_subdir = NULL,
  out_filepath = NULL,
  return_output = TRUE
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

- numobs:

  Number of obesrvations required to return a value of 1.

- db_open:

  An open SQLite database connection created using RSQLite::dbConnect,
  to be queried.

- db:

  Name of SQLITE database on hard disk (stored in "data/sql/"), to be
  queried.

- db_filepath:

  Full filepath to SQLITE database on hard disk, to be queried.

- tab:

  Table name to query in SQLite database.

- table_name:

  Specify name of table in the SQLite database to be queried, if this is
  different from `tab`.

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

A data frame with a 0/1 vector and patid. 1 = presence of code within
the specified time period.

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
"data/extraction/". These options will use a default naming convention.
This can be overwritten using `out_filepath` to manually specify the
location on the hard disk to save. Alternatively, return the data frame
into the R workspace using `return_output = TRUE` and then save onto the
hard disk manually.

Codelists can be specified in three ways. The first is to read the
codelist into R as a character vector and then specify through the
argument `codelist_vector`. The second is codelists stored on the hard
disk, which can = be referred to from the `codelist` argument, but
require a specific underlying directory structure. The codelist on the
hard disk must be stored in a directory called "codelists/analysis/"
relative to the working directory. The codelist must be a .csv file, and
contain a column "medcodeid", "prodcodeid" or "ICD10" depending on the
input for argument `tab`. The input to argument `codelist` must be a
character string of the name of the files (excluding the suffix '.csv').
The third is to specify the codelist through an R data.frame,
`codelist_df`, this must contain a column "medcodeid", "prodcodeid" or
"ICD10" depending on the chosen `tab`. Specifying the codelist this way
will retain all the other columns from `codelist_df` in the queried
output.

The argument `table_name` is only necessary if the name of the table
being queried does not match the CPRD filetype specified in `tab`. This
will occur when `str_match` is used in `cprd_extract` or
`add_to_database` to create the .sqlite database.

## Examples

``` r

## Connect
aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

## Create SQLite database using cprd_extract
cprd_extract(aurum_extract,
filepath = system.file("aurum_data", package = "rcprd"),
filetype = "observation", use_set = FALSE)
#>   |                                                                              |                                                                      |   0%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_001.txt 2026-05-21 21:16:36.248819
#>   |                                                                              |=======================                                               |  33%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_002.txt 2026-05-21 21:16:36.261464
#>   |                                                                              |===============================================                       |  67%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_003.txt 2026-05-21 21:16:36.272495
#>   |                                                                              |======================================================================| 100%

## Define cohort and add index date
pat<-extract_cohort(system.file("aurum_data", package = "rcprd"))
pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")

## Extract a history of type variable prior to index date
extract_ho(pat,
codelist_vector = "187341000000114",
indexdt = "fup_start",
db_open = aurum_extract,
tab = "observation",
return_output = TRUE)
#>    patid ho
#> 1      1  0
#> 2      2  1
#> 3      3  0
#> 4      4  0
#> 5      5  0
#> 6      6  1
#> 7      7  0
#> 8      8  0
#> 9      9  0
#> 10    10  0
#> 11    11  0
#> 12    12  0

## clean up
RSQLite::dbDisconnect(aurum_extract)
unlink(file.path(tempdir(), "temp.sqlite"))
```
