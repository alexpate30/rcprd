# Query an RSQLite database.

Query an RSQLite database stored on the hard disk for observations with
specific codes.

## Usage

``` r
db_query(
  codelist = NULL,
  db_open = NULL,
  db = NULL,
  db_filepath = NULL,
  db_cprd = c("aurum", "gold"),
  tab = c("observation", "drugissue", "clinical", "immunisation", "test", "therapy",
    "hes_primary", "death", "consultation"),
  table_name = NULL,
  codelist_vector = NULL,
  codelist_df = NULL,
  n = NULL,
  rm_duplicates = FALSE
)
```

## Arguments

- codelist:

  Name of codelist to query the database with.

- db_open:

  An open SQLite database connection created using RSQLite::dbConnect,
  to be queried.

- db:

  Name of SQLITE database on hard disk, to be queried.

- db_filepath:

  Full filepath to SQLITE database on hard disk, to be queried.

- db_cprd:

  CPRD Aurum ('aurum') or gold ('gold').

- tab:

  CPRD filetype

- table_name:

  Specify name of table in the SQLite database to be queried, if this is
  different from `tab`.

- codelist_vector:

  Vector of codes to query the database with.

- codelist_df:

  data.frame used to specify the codelist.

- n:

  number of observations to output

- rm_duplicates:

  TRUE/FALSE whether to remove duplicate values (default is FALSE)

## Value

A data.table with observations contained in the specified codelist.

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

Specifying `codelist` requires a specific underlying directory
structure. The codelist on the hard disk must be stored in
"codelists/analysis/" relative to the working directory, must be a .csv
file, and contain a column "medcodeid", "prodcodeid" or "ICD10"
depending on the chosen `tab`. The codelist can also be read in
manually, and supplied as a character vector to `codelist_vector`. If
the codelist is specified through an R data.frame, `codelist_df`, this
must contain a column "medcodeid", "prodcodeid" or "ICD10" depending on
the chosen `tab`. Specifying the codelist this way will retain all the
other columns from `codelist_df` in the queried output.

The argument `table_name` is only necessary if the name of the table
being queried does not match the CPRD filetype specified in `tab`. This
will occur when `str_match` is used in `cprd_extract` or
`add_to_database` to create the .sqlite database.

## Examples

``` r
## Create connection to a temporary database
aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

## Add observation data from all observation files in specified directory
cprd_extract(db = aurum_extract,
filepath = system.file("aurum_data", package = "rcprd"),
filetype = "observation")
#>   |                                                                              |                                                                      |   0%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_001.txt 2026-05-21 21:16:34.724257
#>   |                                                                              |=======================                                               |  33%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_002.txt 2026-05-21 21:16:34.736647
#>   |                                                                              |===============================================                       |  67%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_003.txt 2026-05-21 21:16:34.74738
#>   |                                                                              |======================================================================| 100%

## Query database for a specific medcode
db_query(db_open = aurum_extract,
tab ="observation",
codelist_vector = "187341000000114")
#>     patid consid pracid  obsid    obsdate  enterdate staffid parentobsid
#>    <char> <char>  <int> <char>     <Date>     <Date>  <char>      <char>
#> 1:      1     42      1     81 1955-04-17 1981-10-12      85          35
#> 2:      2     56      1     77 1954-03-17 1932-02-22      24           4
#> 3:      6     40      1     41 1929-09-06 1951-01-12      98          80
#>          medcodeid value numunitid obstypeid numrangelow numrangehigh probobsid
#>             <char> <num>     <int>     <int>       <num>        <num>    <char>
#> 1: 187341000000114    84        79        67          24           22         5
#> 2: 187341000000114    46        92        81          56           30        18
#> 3: 187341000000114    28        20         5          41           97        92

## clean up
RSQLite::dbDisconnect(aurum_extract)
unlink(file.path(tempdir(), "temp.sqlite"))
```
