# Package index

## All functions

- [`add_to_database()`](https://alexpate30.github.io/rcprd/reference/add_to_database.md)
  : Adds a single .txt file to an SQLite database on the hard disk.

- [`combine_query()`](https://alexpate30.github.io/rcprd/reference/combine_query.md)
  : Combine a database query with a cohort.

- [`combine_query(`*`<aurum>`*`)`](https://alexpate30.github.io/rcprd/reference/combine_query.aurum.md)
  : Combine a CPRD aurum database query with a cohort.

- [`combine_query_boolean()`](https://alexpate30.github.io/rcprd/reference/combine_query_boolean.md)
  : Combine a database query with a cohort returning a 0/1 vector
  depending on whether each individual has a recorded code of interest.

- [`combine_query_boolean(`*`<aurum>`*`)`](https://alexpate30.github.io/rcprd/reference/combine_query_boolean.aurum.md)
  : Combine a CPRD aurum database query with a cohort returning a 0/1
  vector depending on whether each individual has a recorded code of
  interest.

- [`connect_database()`](https://alexpate30.github.io/rcprd/reference/connect_database.md)
  : Open connection to SQLite database

- [`cprd_extract()`](https://alexpate30.github.io/rcprd/reference/cprd_extract.md)
  : Adds all the .txt files in a directory, with certain file names, to
  an SQLite database on the hard disk.

- [`create_directory_system()`](https://alexpate30.github.io/rcprd/reference/create_directory_system.md)
  : Create the appropriate directory system to be able to run functions
  without specifying hard filepaths

- [`db_query()`](https://alexpate30.github.io/rcprd/reference/db_query.md)
  : Query an RSQLite database.

- [`delete_directory_system()`](https://alexpate30.github.io/rcprd/reference/delete_directory_system.md)
  :

  Deletes directory system created by `delete_directory_system`

- [`extract_bmi()`](https://alexpate30.github.io/rcprd/reference/extract_bmi.md)
  : Extract most recent BMI score relative to an index date.

- [`extract_cholhdl_ratio()`](https://alexpate30.github.io/rcprd/reference/extract_cholhdl_ratio.md)
  : Extract most recent total cholesterol/high-density lipoprotein ratio
  score relative to an index date.

- [`extract_cohort()`](https://alexpate30.github.io/rcprd/reference/extract_cohort.md)
  : Create cohort from patient files

- [`extract_diabetes()`](https://alexpate30.github.io/rcprd/reference/extract_diabetes.md)
  : Extract diabetes status prior to an index date.

- [`extract_ho()`](https://alexpate30.github.io/rcprd/reference/extract_ho.md)
  : Extract a 'history of' type variable

- [`extract_practices()`](https://alexpate30.github.io/rcprd/reference/extract_practices.md)
  : Combine practice files

- [`extract_smoking()`](https://alexpate30.github.io/rcprd/reference/extract_smoking.md)
  : Extract smoking status prior to index date.

- [`extract_test_data()`](https://alexpate30.github.io/rcprd/reference/extract_test_data.md)
  : Extract test data.

- [`extract_test_data_var()`](https://alexpate30.github.io/rcprd/reference/extract_test_data_var.md)
  : Extract standard deviation of all test data values over a specified
  time period relative to an index date.

- [`extract_test_recent()`](https://alexpate30.github.io/rcprd/reference/extract_test_recent.md)
  : Extract test data.

- [`extract_time_until()`](https://alexpate30.github.io/rcprd/reference/extract_time_until.md)
  : Extract a 'time until' type variable

- [`extract_txt_char()`](https://alexpate30.github.io/rcprd/reference/extract_txt_char.md)
  : Read in txt file with all colClasses = "character"

- [`extract_txt_cons()`](https://alexpate30.github.io/rcprd/reference/extract_txt_cons.md)
  : Read in raw .txt consultation file

- [`extract_txt_death()`](https://alexpate30.github.io/rcprd/reference/extract_txt_death.md)
  : Read in raw ONS death data file

- [`extract_txt_drug()`](https://alexpate30.github.io/rcprd/reference/extract_txt_drug.md)
  : Read in raw .txt drugissue file

- [`extract_txt_hes_primary()`](https://alexpate30.github.io/rcprd/reference/extract_txt_hes_primary.md)
  : Read in raw HES primary diagnoses file

- [`extract_txt_linkage()`](https://alexpate30.github.io/rcprd/reference/extract_txt_linkage.md)
  : Read in linkage eligibility file

- [`extract_txt_obs()`](https://alexpate30.github.io/rcprd/reference/extract_txt_obs.md)
  : Read in raw .txt observation file

- [`extract_txt_pat()`](https://alexpate30.github.io/rcprd/reference/extract_txt_pat.md)
  : Read in raw .txt patient file

- [`extract_txt_prac()`](https://alexpate30.github.io/rcprd/reference/extract_txt_prac.md)
  : Read in raw .txt practice file

- [`extract_txt_prob()`](https://alexpate30.github.io/rcprd/reference/extract_txt_prob.md)
  : Read in raw .txt problem file

- [`extract_txt_ref()`](https://alexpate30.github.io/rcprd/reference/extract_txt_ref.md)
  : Read in raw .txt referral file

- [`implement_output()`](https://alexpate30.github.io/rcprd/reference/implement_output.md)
  : Internal function to implement saving extracted variable to disk or
  returning into R workspace.
