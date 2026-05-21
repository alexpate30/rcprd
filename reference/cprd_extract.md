# Adds all the .txt files in a directory, with certain file names, to an SQLite database on the hard disk.

Add the raw data from more than one of the CPRD flatfiles to an SQLite
database.

## Usage

``` r
cprd_extract(
  db,
  filepath,
  filetype = c("observation", "drugissue", "referral", "problem", "consultation",
    "hes_primary", "death"),
  nrows = -1,
  select = NULL,
  subset_patids = NULL,
  use_set = FALSE,
  extract_txt_func = NULL,
  str_match = NULL,
  table_name = NULL,
  rm_duplicates = FALSE
)
```

## Arguments

- db:

  An open SQLite database connection created using RSQLite::dbConnect.

- filepath:

  Path to directory containing .txt files.

- filetype:

  Type of CPRD Aurum file (observation, drugissue, referral, problem,
  consultation, hes_primary, death)

- nrows:

  Number of rows to read in from .txt file.

- select:

  Vector of column names to select before adding to the SQLite database.

- subset_patids:

  Patient id's to subset the .txt file on before adding to the SQLite
  database.

- use_set:

  Reduce subset_patids to just those with a corresponding set value to
  the .txt file being read in. Can greatly improve computational
  efficiency when subset_patids is large. See vignette XXXX for more
  details.

- extract_txt_func:

  User-defined function to read the .txt file into R.

- str_match:

  Character vector to match on when searching for file names to add to
  the database.

- table_name:

  Name of table in SQLite database that the data will be added to.

- rm_duplicates:

  TRUE/FALSE whether to remove duplicate values (default is FALSE).

## Value

Adds .txt file to SQLite database on hard disk.

## Details

By default, will add files that contain `filetype` in the file name to a
table named `filetype` in the SQLite database. If `str_match` is
specified, will add files that contain `str_match` in the file name to a
table named `str_match` in the SQLite database. In this case, `filetype`
will still be used to choose which function reads in and formats the raw
data, although this can be overwritten with `extract_txt_func`. If
argument `table_name` is specified, data will be added to a table called
`table_name` in the SQLite database.

Currently, rcprd only deals with
`filetype = c("observation", "drugissue", "referral", "problem", "consultation", "hes_primary", "death")`
by default. However, by using `str_match` and `extract_txt_func`, the
user can manually search for files with any string in the file name, and
read them in and format using a user-defined function. This means the
user is not restricted to only adding the pre-defined file types to the
SQLite database.

If `use_set = FALSE`, then `subset_patids` should be a vector of patid's
that the .txt files will be subsetted on before adding to the SQLite
database. If `use_set = TRUE`, then `subset_patids` should be a
dataframe with two columns, `patid` and `set`, where `set` corresponds
to the number in the file name following the word 'set'. This
functionality is provided to increase computational efficiency when
subsetting to a cohort of patients which is very large (millions). This
can be a computationally expensive process as each flatfile being read
in, must be cross matched with a large vector . The CPRD flatfiles are
split up into groups which can be identified from their naming
convention. Patients from set 1, will have their data in DrugIssue,
Observation, etc, all with the same "set" suffix in the flatfile name.
We can utilise this to speed up the process of subsetting the data from
the flatfiles to only those with patids in subset.patid. Instead we
subset to those with patids in subset_patids, and with the corresponding
value of "set", which matches the suffix "set" in the CPRD flatfile file
name. For example, patients in the Patient file which had suffix "set1",
will have their medical data in the Observation file with suffix "set1".
When subsetting the Observation file to those in subset_patids (our
cohort), we only need to do so for patients who were also in the patient
file with suffix "set1". If the cohort of patients for which you want to
subset the data to is very small, the computational gains from this
argument are minor and it can be ignored.

The function for reading in the .txt file will be chosen from a set of
functions provided with rcprd, based on the filetype (`filetype`).
`extract_txt_func` does not need to be specified unless wanting to
manually define the function for doing this. This may be beneficial if
wanting to change variable formats, or if the variables in the .txt
files change in future releases of CPRD AURUM and rcprd has not been
updated.

## Examples

``` r
## Create connection to a temporary database
aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

## Add observation data from all observation files in specified directory
cprd_extract(db = aurum_extract,
filepath = system.file("aurum_data", package = "rcprd"),
filetype = "observation")
#>   |                                                                              |                                                                      |   0%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_001.txt 2026-05-21 21:16:34.3515
#>   |                                                                              |=======================                                               |  33%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_002.txt 2026-05-21 21:16:34.36424
#>   |                                                                              |===============================================                       |  67%
#> Adding /home/runner/work/_temp/Library/rcprd/aurum_data/aurum_allpatid_set1_extract_observation_003.txt 2026-05-21 21:16:34.375075
#>   |                                                                              |======================================================================| 100%

## Query database
RSQLite::dbGetQuery(aurum_extract, 'SELECT * FROM observation', n = 3)
#>   patid consid pracid obsid obsdate enterdate staffid parentobsid
#> 1     1     33      1   100  -15931      -994      79          95
#> 2     1     66      1    46  -13782    -15232      34          17
#> 3     1     41      1    53  -20002      8845      35          79
#>           medcodeid value numunitid obstypeid numrangelow numrangehigh
#> 1   498521000006119    48        16        20          28           86
#> 2         401539014    22         1         2          27            8
#> 3 13483031000006114    17        78        13          87           41
#>   probobsid
#> 1        54
#> 2        35
#> 3        74

## clean up
RSQLite::dbDisconnect(aurum_extract)
unlink(file.path(tempdir(), "temp.sqlite"))
```
