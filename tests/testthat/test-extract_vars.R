###
### Tests for variable extraction programs
###
testthat::test_that("Test extract_ho, extract_time_until and extract_test_data, and specification of underlying directory systems", {

  ### Connect
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Extract data using cprd_Extract
  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "observation", use_set = FALSE)

  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "drugissue", use_set = FALSE)

  ### Define pat and add index date and censoring date
  pat <- extract_txt_pat(system.file("aurum_data", "aurum_allpatid_set1_extract_patient_001.txt", package = "rcprd"))
  pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")
  pat$fup_end <- as.Date("01/01/2000", format = "%d/%m/%Y")

  ### Define codelist
  codelist <- "51268016"

  ###
  ### Extract a history of type variable using extract_ho
  ho <- extract_ho(pat,
                   codelist_vector = codelist,
                   indexdt = "fup_start",
                   db_open = aurum_extract,
                   tab = "observation",
                   return_output = TRUE)

  testthat::expect_equal(nrow(ho), 6)
  testthat::expect_equal(colnames(ho), c("patid", "ho"))
  testthat::expect_equal(ho$ho, c(0, 0, 0, 0, 0, 1))

  ###
  ### Extract a medication history of type variable using extract_ho
  ho.drug <- extract_ho(pat,
                        codelist_vector = "1026541000033111",
                        indexdt = "fup_start",
                        db_open = aurum_extract,
                        tab = "drugissue",
                        return_output = TRUE)

  testthat::expect_equal(nrow(ho.drug), 6)
  testthat::expect_equal(colnames(ho.drug), c("patid", "ho"))
  testthat::expect_equal(ho.drug$ho, c(0, 0, 0, 0, 1, 0))

  ###
  ### Extract a time until variable using extract_time_until
  time_until <- extract_time_until(pat,
                                   codelist_vector = codelist,
                                   indexdt = "fup_start",
                                   censdt = "fup_end",
                                   db_open = aurum_extract,
                                   tab = "observation",
                                   return_output = TRUE)

  testthat::expect_equal(nrow(time_until), 6)
  testthat::expect_equal(colnames(time_until), c("patid", "var_time", "var_indicator"))
  testthat::expect_equal(time_until$var_time, c(16436, 16436,  16436,  16436,  16436,  2862))
  testthat::expect_equal(time_until$var_indicator, c(0, 0,  0,  0,  0,  1))

  ### Change code list for test data functions, as previous code list only had one observation per patient
  codelist <- "498521000006119"

  ###
  ### Extract tests in the past
  test_data <- extract_test_data(pat,
                                 codelist_vector = codelist,
                                 indexdt = "fup_start",
                                 db_open = aurum_extract,
                                 time_prev = Inf,
                                 return_output = TRUE)

  testthat::expect_equal(nrow(test_data), 6)
  testthat::expect_equal(colnames(test_data), c("patid", "value"))
  testthat::expect_equal(test_data$value, c(NA, NA,  NA,  NA,  18,  NA))

  ###
  ### Extract all test results using extract_test_data
  test_data <- extract_test_data(pat,
                                 codelist_vector = codelist,
                                 indexdt = "fup_start",
                                 time_post = Inf,
                                 numobs = Inf,
                                 keep_numunit = TRUE,
                                 db_open = aurum_extract,
                                 return_output = TRUE)

  testthat::expect_equal(nrow(test_data), 8)
  testthat::expect_equal(colnames(test_data), c("patid", "value", "numunitid", "medcodeid", "obsdate"))
  testthat::expect_equal(test_data$value, c(NA, 75, 41, NA, NA, 32, 18, NA))

  ###
  ### Extract standard deviation of all test results using extract_test_var
  test_data <- extract_test_data_var(pat,
                                     codelist_vector = codelist,
                                     indexdt = "fup_start",
                                     db_open = aurum_extract,
                                     time_prev = Inf,
                                     time_post = Inf,
                                     return_output = TRUE)

  testthat::expect_equal(nrow(test_data), 6)
  testthat::expect_equal(colnames(test_data), c("patid", "value_var"))
  testthat::expect_equal(sum(is.na(test_data$value_var)), 4)

  ## clean up
  RSQLite::dbDisconnect(aurum_extract)
  unlink(file.path(tempdir(), "temp.sqlite"))

  ###
  ### Create a temporary directory to re-run these functions and save to disk automatically, and automatically look for SQLite database in data/sql
  ### Will recreate variables for ho and compare with ho created for previous test
  ###

  ### Sset on.exit to restore working directory after tests are run
  oldwd <- getwd()
  on.exit(setwd(oldwd))

  ### set working directory to tempdir
  tempdir <- tempdir()
  setwd(tempdir)

  ### Create directory system
  create_directory_system()

  ### Create Aurum database in data/sql

  ### Connect
  aurum_extract <- connect_database("data/sql/temp.sqlite")

  ### Extract data using cprd_extract
  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "observation", use_set = FALSE)

  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "drugissue", use_set = FALSE)


  ### Define codelist
  codelist <- data.frame(medcodeid = "51268016")
  write.csv(codelist, "codelists/analysis/mylist.med.csv")
  codelist <- data.frame(prodcodeid = "1026541000033111")
  write.csv(codelist, "codelists/analysis/mylist.drug.csv")

  ### Extract a history of type variable and save to disc automatically, by just specifying name of database
  extract_ho(pat,
             codelist = "mylist.med",
             indexdt = "fup_start",
             db = "temp",
             tab = "observation",
             out_save_disk = TRUE)

  ### Read from disk
  ho.disk <- readRDS("data/extraction/var_ho.rds")
  testthat::expect_equal(ho, ho.disk)

  ### Extract a history of type variable and save to disc automatically, by just specifying name of database
  extract_ho(pat,
             codelist = "mylist.drug",
             indexdt = "fup_start",
             db = "temp",
             tab = "drugissue",
             out_save_disk = TRUE)

  ### Read from disk
  ho.disk.drug <- readRDS("data/extraction/var_ho.rds")
  testthat::expect_equal(ho.drug, ho.disk.drug)

  ### Extract a history of type variable and save to disk using out_subdir
  extract_ho(pat,
             codelist = "mylist.med",
             indexdt = "fup_start",
             db = "temp",
             tab = "observation",
             out_subdir = "cohort",
             out_save_disk = TRUE)

  ### Read from disk
  ho.disk <- readRDS("data/extraction/cohort/var_ho.rds")
  testthat::expect_equal(ho, ho.disk)

  ### Extract a history of type variable and save to disk manually specifying filepath for output and db
  extract_ho(pat,
             codelist = "mylist.med",
             indexdt = "fup_start",
             db_filepath = "data/sql/temp.sqlite",
             tab = "observation",
             out_filepath = "data/extraction/eggs.rds",
             out_save_disk = TRUE)

  ### Read from disk
  ho.disk <- readRDS("data/extraction/eggs.rds")
  testthat::expect_equal(ho, ho.disk)

  ## clean up
  RSQLite::dbDisconnect(aurum_extract)
  delete_directory_system()
  testthat::expect_false(file.exists("data/sql/temp.sqlite"))
  testthat::expect_false(file.exists("data/extraction/eggs.rds"))
  testthat::expect_false(file.exists("codelists/analysis/mylist.med.csv"))

})


###
### BMI
testthat::test_that("BMI", {

  ### Connect
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Extract data using cprd_Extract
  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "observation", use_set = FALSE)

  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "drugissue", use_set = FALSE)

  ### Define pat and add index date and censoring date
  pat <- extract_txt_pat(system.file("aurum_data", "aurum_allpatid_set1_extract_patient_001.txt", package = "rcprd"))
  pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")
  pat$fup_end <- as.Date("01/01/2000", format = "%d/%m/%Y")

  ### Extract BMI
  var <- extract_bmi(cohort = pat,
                     codelist_bmi_vector = 498521000006119,
                     codelist_weight_vector = 401539014,
                     codelist_height_vector = 13483031000006114,
                     indexdt = "indexdt",
                     time_prev = Inf,
                     time_post = Inf,
                     db_open = aurum_extract,
                     return_output = TRUE)

  testthat::expect_equal(nrow(var), 6)
  testthat::expect_equal(colnames(var), c("patid", "bmi"))
  testthat::expect_equal(var$bmi, c(NA, 41, NA, NA, 32, NA))

  ## clean up
  RSQLite::dbDisconnect(aurum_extract)
  unlink(file.path(tempdir(), "temp.sqlite"))

})


###
### Cholhdl ratio
testthat::test_that("Cholhdl ratio", {

  ### Connect
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Extract data using cprd_Extract
  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "observation", use_set = FALSE)

  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "drugissue", use_set = FALSE)

  ### Define pat and add index date and censoring date
  pat <- extract_txt_pat(system.file("aurum_data", "aurum_allpatid_set1_extract_patient_001.txt", package = "rcprd"))
  pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")
  pat$fup_end <- as.Date("01/01/2000", format = "%d/%m/%Y")

  ### Extract cholhdl_ratio
  var <- extract_cholhdl_ratio(cohort = pat,
                               codelist_ratio_vector = 498521000006119,
                               codelist_chol_vector = 401539014,
                               codelist_hdl_vector = 13483031000006114,
                               indexdt = "indexdt",
                               time_prev = Inf,
                               time_post = Inf,
                               db_open = aurum_extract,
                               return_output = TRUE)

  ## NB: Value for cholhdl_ratio test are same as BMI test, because its the "ratio" medcode id that is finding the values,
  ## As opposed to finding them seperately and calculating the value from the components, which would be different
  testthat::expect_equal(nrow(var), 6)
  testthat::expect_equal(colnames(var), c("patid", "cholhdl_ratio"))
  testthat::expect_equal(var$cholhdl_ratio, c(NA, 41, NA, NA, 32, NA))

  ## clean up
  RSQLite::dbDisconnect(aurum_extract)
  unlink(file.path(tempdir(), "temp.sqlite"))

})


###
### Diabetes
testthat::test_that("Diabetes", {

  ### Connect
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Extract data using cprd_Extract
  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "observation", use_set = FALSE)

  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "drugissue", use_set = FALSE)

  ### Define pat and add index date and censoring date
  pat <- extract_txt_pat(system.file("aurum_data", "aurum_allpatid_set1_extract_patient_001.txt", package = "rcprd"))
  pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")
  pat$fup_end <- as.Date("01/01/2000", format = "%d/%m/%Y")

  ### Extract diabetes
  var <- extract_diabetes(cohort = pat,
                          codelist_type1_vector = 498521000006119,
                          codelist_type2_vector = 1784724014,
                          indexdt = "indexdt",
                          db_open = aurum_extract)

  testthat::expect_equal(nrow(var), 6)
  testthat::expect_equal(colnames(var), c("patid", "diabetes"))
  testthat::expect_equal(as.character(var$diabetes), c("Absent", "Absent", "Absent", "Absent", "Type1", "Type2"))

  ## clean up
  RSQLite::dbDisconnect(aurum_extract)
  unlink(file.path(tempdir(), "temp.sqlite"))

})


###
### Smoking
testthat::test_that("Smoking", {

  ### Connect
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Extract data using cprd_Extract
  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "observation", use_set = FALSE)

  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "drugissue", use_set = FALSE)

  ### Define pat and add index date and censoring date
  pat <- extract_txt_pat(system.file("aurum_data", "aurum_allpatid_set1_extract_patient_001.txt", package = "rcprd"))
  pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")
  pat$fup_end <- as.Date("01/01/2000", format = "%d/%m/%Y")

  ### Extract smoking
  var <- extract_smoking(cohort = pat,
                         codelist_non_vector = 498521000006119,
                         codelist_ex_vector = 401539014,
                         codelist_light_vector = 128011000000115,
                         codelist_mod_vector = 380389013,
                         codelist_heavy_vector = 13483031000006114,
                         indexdt = "indexdt",
                         db_open = aurum_extract)

  testthat::expect_equal(nrow(var), 6)
  testthat::expect_equal(colnames(var), c("patid", "smoking"))
  testthat::expect_equal(as.character(var$smoking), c(NA, NA, NA, "Heavy", "Ex-smoker", "Moderate"))

  ## clean up
  RSQLite::dbDisconnect(aurum_extract)
  unlink(file.path(tempdir(), "temp.sqlite"))

})


###
### Impotence
testthat::test_that("Impotence", {

  ### Connect
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Extract data using cprd_Extract
  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "observation", use_set = FALSE)

  cprd_extract(aurum_extract,
               filepath = system.file("aurum_data", package = "rcprd"),
               filetype = "drugissue", use_set = FALSE)

  ### Define pat and add index date and censoring date
  pat <- extract_txt_pat(system.file("aurum_data", "aurum_allpatid_set1_extract_patient_001.txt", package = "rcprd"))
  pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")
  pat$fup_end <- as.Date("01/01/2000", format = "%d/%m/%Y")

  ### Extract impotence
  var <- extract_impotence(cohort = pat,
                           codelist_med_vector = 498521000006119,
                           codelist_drug_vector = 3092241000033113,
                           indexdt = "indexdt",
                           db_open = aurum_extract)

  testthat::expect_equal(nrow(var), 6)
  testthat::expect_equal(colnames(var), c("patid", "impotence"))
  testthat::expect_equal(var$impotence, c(0, 0, 0, 0, 1, 0))

  ## clean up
  RSQLite::dbDisconnect(aurum_extract)
  unlink(file.path(tempdir(), "temp.sqlite"))

})
