testthat::test_that("Extract multiple ways and expect equivalence. Testing add_to_database and cprd_extract", {

  ###
  ### Attempt 1

  ### Open connection
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Add observation and drugissue to database manually
  ## Obs
  add_to_database(filepath = system.file("aurum_data", "aurum_allpatid_set1_extract_observation_001.txt", package = "rcprd"),
                  filetype = "observation", nrows = -1, select = NULL, subset_patids = c(1,3,4,6), use_set = FALSE, db = aurum_extract, overwrite = TRUE)
  add_to_database(filepath = system.file("aurum_data", "aurum_allpatid_set1_extract_observation_002.txt", package = "rcprd"),
                  filetype = "observation", subset_patids = c(1,3,4,6), db = aurum_extract, append = TRUE)
  add_to_database(filepath = system.file("aurum_data", "aurum_allpatid_set1_extract_observation_003.txt", package = "rcprd"),
                  filetype = "observation", subset_patids = c(1,3,4,6), db = aurum_extract, append = TRUE)
  ## Drugissue
  add_to_database(filepath = system.file("aurum_data", "aurum_allpatid_set1_extract_drugissue_001.txt", package = "rcprd"),
                  filetype = "drugissue", nrows = -1, select = NULL, subset_patids = c(1,3,4,6), use_set = FALSE, aurum_extract, overwrite = TRUE)
  add_to_database(filepath = system.file("aurum_data", "aurum_allpatid_set1_extract_drugissue_002.txt", package = "rcprd"),
                  filetype = "drugissue", nrows = -1, select = NULL, subset_patids = c(1,3,4,6), use_set = FALSE, aurum_extract, append = TRUE)
  add_to_database(filepath = system.file("aurum_data", "aurum_allpatid_set1_extract_drugissue_003.txt", package = "rcprd"),
                  filetype = "drugissue", nrows = -1, select = NULL, subset_patids = c(1,3,4,6), use_set = FALSE, aurum_extract, append = TRUE)

  ### Save output
  obs1 <- RSQLite::dbGetQuery(aurum_extract, 'SELECT * FROM observation')
  drugissue1 <- RSQLite::dbGetQuery(aurum_extract, 'SELECT * FROM drugissue')
  testthat::expect_equal(RSQLite::dbListTables(aurum_extract), c("drugissue", "observation"))

  ### Disconnect
  RSQLite::dbDisconnect(aurum_extract)

  ###
  ### Attempt 2

  ### Reconnect
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Extract data using cprd_Extract
  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "observation", subset_patids = c(1,3,4,6), use_set = FALSE)

  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "drugissue", subset_patids = c(1,3,4,6), use_set = FALSE)

  ### Save output
  obs2 <- RSQLite::dbGetQuery(aurum_extract, 'SELECT * FROM observation')
  drugissue2 <- RSQLite::dbGetQuery(aurum_extract, 'SELECT * FROM drugissue')
  testthat::expect_equal(RSQLite::dbListTables(aurum_extract), c("drugissue", "observation"))

  ### Disconnect
  RSQLite::dbDisconnect(aurum_extract)

  ###
  ### Attempt 3

  ### Reconnect
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Define pat
  pat <- extract_txt_pat(system.file("aurum_data", "aurum_allpatid_set1_extract_patient_001.txt", package = "rcprd"), set = TRUE)
  pat <- subset(pat, patid %in% c(1,3,4,6))

  ### Add observation files
  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "observation", nrows = -1, select = NULL, subset_patids = pat, use_set = TRUE)

  ### Add drugissue files
  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "drugissue", nrows = -1, select = NULL, subset_patids = pat, use_set = TRUE)

  ### Save output
  obs3 <- RSQLite::dbGetQuery(aurum_extract, 'SELECT * FROM observation')
  drugissue3 <- RSQLite::dbGetQuery(aurum_extract, 'SELECT * FROM drugissue')
  testthat::expect_equal(RSQLite::dbListTables(aurum_extract), c("drugissue", "observation"))

  ### Disconnect
  RSQLite::dbDisconnect(aurum_extract)

  ###
  ### Attempt 4 (manually define str_match and extract_txt_func)

  ### Reconnect
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Extract data using cprd_Extract
  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "observation", subset_patids = c(1,3,4,6),
               extract_txt_func = extract_txt_obs, str_match = "observation", use_set = FALSE)

  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "drugissue", subset_patids = c(1,3,4,6),
               extract_txt_func = extract_txt_drug, str_match = "drugissue", use_set = FALSE)

  ### Save output
  obs4 <- RSQLite::dbGetQuery(aurum_extract, 'SELECT * FROM observation')
  drugissue4 <- RSQLite::dbGetQuery(aurum_extract, 'SELECT * FROM drugissue')
  testthat::expect_equal(RSQLite::dbListTables(aurum_extract), c("drugissue", "observation"))

  ### Disconnect
  RSQLite::dbDisconnect(aurum_extract)

  ###
  ### Attempt 5 (manually define str_match and table_name)

  ### Reconnect
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Extract data using cprd_Extract
  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "observation", subset_patids = c(1,3,4,6),
               str_match = "observation", table_name = "scrambled", use_set = FALSE)

  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "drugissue", subset_patids = c(1,3,4,6),
               str_match = "drugissue", table_name = "eggs", use_set = FALSE)

  ### Save output
  obs5 <- RSQLite::dbGetQuery(aurum_extract, 'SELECT * FROM scrambled')
  drugissue5 <- RSQLite::dbGetQuery(aurum_extract, 'SELECT * FROM eggs')
  testthat::expect_equal(RSQLite::dbListTables(aurum_extract), c("drugissue", "eggs", "observation", "scrambled"))

  ### Disconnect
  RSQLite::dbDisconnect(aurum_extract)

  ### Test for equivalence between extracts
  testthat::expect_equal(obs1, obs2)
  testthat::expect_equal(obs1, obs3)
  testthat::expect_equal(obs1, obs4)
  testthat::expect_equal(obs1, obs5)
  testthat::expect_equal(drugissue1, drugissue2)
  testthat::expect_equal(drugissue1, drugissue3)
  testthat::expect_equal(drugissue1, drugissue4)
  testthat::expect_equal(drugissue1, drugissue5)

  ###
  ### Attempt 6 (expect an error due to no filenames)

  ### Reconnect
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Extract data using cprd_Extract
  testthat::expect_error(
    cprd_extract(aurum_extract,
                 filepath = system.file("aurum_data", package = "rcprd"),
                 filetype = "observation", subset_patids = c(1,3,4,6),
                 str_match = "eggs", use_set = FALSE))

  ## clean up
  RSQLite::dbDisconnect(aurum_extract)
  unlink(file.path(tempdir(), "temp.sqlite"))

})

###
### Tests for db queries
###
testthat::test_that("Test low-level db query functions", {

  ### Currently empty as thinking lots of these will be covered by the extract variable functions
  ### Add here later if some functionaliy is missing

})


###
### Tests for creating patient file
###
testthat::test_that("Test creation of cohort", {

  ### Create a number of different ways
  cohort1 <- extract_cohort(filepath = system.file("aurum_data", package = "rcprd"))
  testthat::expect_equal(cohort1$patid, as.character(1:12))
  testthat::expect_equal(nrow(cohort1), 12)
  testthat::expect_equal(ncol(cohort1), 12)

  ### Create a number of different ways
  cohort2 <- extract_cohort(filepath = system.file("aurum_data", package = "rcprd"),
                            set = TRUE)
  testthat::expect_equal(cohort2$patid, as.character(1:12))
  testthat::expect_true("set" %in% colnames(cohort2))
  testthat::expect_equal(nrow(cohort2), 12)
  testthat::expect_equal(ncol(cohort2), 13)

  ### Create a number of different ways
  cohort3 <- extract_cohort(filepath = system.file("aurum_data", package = "rcprd"),
                            patids = as.character(c(1,2,3)),
                            set = TRUE)
  testthat::expect_equal(cohort3$patid, as.character(1:3))
  testthat::expect_true("set" %in% colnames(cohort3))
  testthat::expect_equal(nrow(cohort3), 3)
  testthat::expect_equal(ncol(cohort3), 13)

  ### Create a number of different ways
  cohort4 <- extract_cohort(filepath = system.file("aurum_data", package = "rcprd"),
                            patids = as.character(c(1,2,3)),
                            select = c("patid", "yob"))
  testthat::expect_equal(cohort4$patid, as.character(1:3))
  testthat::expect_equal(nrow(cohort4), 3)
  testthat::expect_equal(ncol(cohort4), 2)

})





