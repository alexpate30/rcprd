#' Extract test data.
#'
#' @description
#' Query an RSQLite database and return a data frame containing the most recent test result that meets specified criteria.
#'
#' @param cohort Cohort of individuals to extract the 'history of' variable for.
#' @param varname Name of variable in the outputted data frame.
#' @param codelist Name of codelist (stored on hard disk) to query the database with.
#' @param codelist_vector Vector of codes to query the database with.
#' @param codelist_df data.frame used to specify the codelist.
#' @param indexdt Name of variable in `cohort` which specifies the index date. The extracted variable will be calculated relative to this.
#' @param t Number of days after \code{indexdt} at which to extract the variable.
#' @param t_varname Whether to alter the variable name in the outputted data frame to reflect `t`.
#' @param time_prev Number of days prior to index date to look for codes.
#' @param time_post Number of days after index date to look for codes.
#' @param lower_bound Lower bound for returned values.
#' @param upper_bound Upper bound for returned values.
#' @param numobs Number of test results to return. Will return most recent values that are in the valid time and bound ranges.
#' @param keep_numunit TRUE/FALSE whether to keep numunitid, medcodeid and obsdate in the outputted dataset.
#' @param db_open An open SQLite database connection created using RSQLite::dbConnect, to be queried.
#' @param db Name of SQLITE database on hard disk (stored in "data/sql/"), to be queried.
#' @param db_filepath Full filepath to SQLITE database on hard disk, to be queried.
#' @param table_name Specify name of table in the SQLite database to be queried, if this is different from 'observation'.
#' @param out_save_disk If `TRUE` will attempt to save outputted data frame to directory "data/extraction/".
#' @param out_subdir Sub-directory of "data/extraction/" to save outputted data frame into.
#' @param out_filepath Full filepath and filename to save outputted data frame into.
#' @param return_output If `TRUE` will return outputted data frame into R workspace.
#'
#' @details Specifying `db` requires a specific underlying directory structure. The SQLite database must be stored in "data/sql/" relative to the working directory.
#' If the SQLite database is accessed through `db`, the connection will be opened and then closed after the query is complete. The same is true if
#' the database is accessed through `db_filepath`. A connection to the SQLite database can also be opened manually using `RSQLite::dbConnect`, and then
#' using the object as input to parameter `db_open`. After wards, the connection must be closed manually using `RSQLite::dbDisconnect`. If `db_open` is specified, this will take precedence over `db` or `db_filepath`.
#'
#' If `out_save_disk = TRUE`, the data frame will automatically be written to an .rds file in a subdirectory "data/extraction/" of the working directory.
#' This directory structure must be created in advance. `out_subdir` can be used to specify subdirectories within "data/extraction/". These options will use a default naming convetion. This can be overwritten
#' using `out_filepath` to manually specify the location on the hard disk to save. Alternatively, return the data frame into the R workspace using `return_output = TRUE`
#' and then save onto the hard disk manually.
#'
#' Codelists can be specified in three ways. The first is to read the codelist into R as a character vector and then specify through the argument
#' `codelist_vector`. The second is codelists stored on the hard disk, which can = be referred to from the `codelist` argument, but require a specific underlying directory structure.
#' The codelist on the hard disk must be stored in a directory called "codelists/analysis/" relative to the working directory. The codelist must be a .csv file, and
#' contain a column "medcodeid", "prodcodeid" or "ICD10" depending on the input for argument `tab`. The input to argument `codelist` must be a character string of
#' the name of the files (excluding the suffix '.csv').  The third is to specify the codelist through an R data.frame, `codelist_df`,
#' this must contain a column "medcodeid", "prodcodeid" or "ICD10" depending on the chosen `tab`. Specifying the codelist this way will retain all the other
#' columns from `codelist_df` in the queried output.
#'
#' Currently only returns most recent test result. This will be updated to return more than one most recent test result if specified.
#'
#' The argument `table_name` is only necessary if the name of the table being queried does not match 'observation'. This will occur when
#' `str_match` is used in `cprd_extract` or `add_to_database` to create the .sqlite database.
#'
#' @returns A data frame containing all test results that meets required criteria.
#'
#' @examples
#'
#' ## Connect
#' aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))
#'
#' ## Create SQLite database using cprd_extract
#' cprd_extract(aurum_extract,
#' filepath = system.file("aurum_data", package = "rcprd"),
#' filetype = "observation", use_set = FALSE)
#'
#' ## Define cohort and add index date
#' pat<-extract_cohort(system.file("aurum_data", package = "rcprd"))
#' pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")
#'
#' ## Extract most recent test value prior to index date
#' extract_test_data(pat,
#' codelist_vector = "187341000000114",
#' indexdt = "fup_start",
#' db_open = aurum_extract,
#' time_prev = Inf,
#' return_output = TRUE)
#'
#' ## clean up
#' RSQLite::dbDisconnect(aurum_extract)
#' unlink(file.path(tempdir(), "temp.sqlite"))
#'
#' @export
extract_test_data <- function(cohort,
                              varname = NULL,
                              codelist = NULL,
                              codelist_vector = NULL,
                              codelist_df = NULL,
                              indexdt,
                              t = NULL,
                              t_varname = TRUE,
                              time_prev = Inf,
                              time_post = 0,
                              lower_bound = -Inf,
                              upper_bound = Inf,
                              numobs = 1,
                              keep_numunit = FALSE,
                              db_open = NULL,
                              db = NULL,
                              db_filepath = NULL,
                              table_name = NULL,
                              out_save_disk = FALSE,
                              out_subdir = NULL,
                              out_filepath = NULL,
                              return_output = FALSE){

  #           varname = NULL
  #           codelist = "edh_sbp_medcodeid"
  #           cohort = cohortZ
  #           indexdt = "fup_start"
  #           t = 0
  #           t_varname = TRUE
  #           time_prev = 365.25*5
  #           time_post = 0
  #           lower_bound = -Inf
  #           upper_bound = Inf
  #           db = "aurum_small"
  #           db_filepath = NULL
  #           out_save_disk = FALSE
  #           out_filepath = NULL
  #           out_subdir = NULL
  #           return_output = TRUE

  ### Preparation
  ## Add index date variable to cohort and change indexdt based on t
  cohort <- prep_cohort(cohort, indexdt, t)
  ## Assign variable name if unspecified
  if (is.null(varname)){
    varname <- "value"
  }
  ## Change variable name based off time point specified for extraction
  varname <- prep_varname(varname, t, t_varname)
  ## Create named subdirectory if it doesn't exist
  prep_subdir(out_subdir)

  ### Run a database query
  db.qry <- db_query(codelist,
                     db_open = db_open,
                     db = db,
                     db_filepath = db_filepath,
                     tab = "observation",
                     table_name = table_name,
                     codelist_vector = codelist_vector,
                     codelist_df = codelist_df)

  ### Get test data for individuals in cohort, within time range and remove outliers
  variable_dat <- combine_query(db_query = db.qry,
                                cohort = cohort,
                                query_type = "test",
                                time_prev = time_prev,
                                time_post = time_post,
                                lower_bound = lower_bound,
                                upper_bound = upper_bound,
                                numobs = numobs)

  ### Create dataframe of cohort and the variable of interest
  variable_dat <- merge(dplyr::select(cohort, patid), variable_dat, by.x = "patid", by.y = "patid", all.x = TRUE)

  ### Create vector of variables to reduce to
  keep_vars <- c("patid", "value")
  if (keep_numunit == TRUE){
    keep_vars <- append(keep_vars, c("numunitid", "medcodeid", "obsdate"))
  }
  if (!is.null(codelist_df)){
    keep_vars <- append(keep_vars, colnames(codelist_df))
  }
  ### Remove duplicates
  keep_vars <- keep_vars[!duplicated(keep_vars)]

  ### Reduce variable_dat to these vars
  variable_dat <- variable_dat[,keep_vars]

  ### Change name of variable to varname
  colnames(variable_dat)[colnames(variable_dat) == "value"] <- varname

  implement_output(variable_dat, varname, out_save_disk, out_subdir, out_filepath, return_output)

}
