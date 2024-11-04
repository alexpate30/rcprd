#' Extract a 'history of' type variable
#'
#' @description
#' Query an RSQLite database and return a data frame with a 0/1 vector depending on whether each individual has at least one observation with relevant code between
#' a specified time period.
#'
#' @param cohort Cohort of individuals to extract the 'history of' variable for.
#' @param varname Name of variable in the outputted data frame.
#' @param codelist Name of codelist (stored on hard disk) to query the database with.
#' @param codelist_vector Vector of codes to query the database with. This takes precedent over `codelist` if both are specified.
#' @param indexdt Name of variable in `cohort` which specifies the index date. The extracted variable will be calculated relative to this.
#' @param t Number of days after \code{indexdt} at which to extract the variable.
#' @param t_varname Whether to alter the variable name in the outputted data frame to reflect `t`.
#' @param time_prev Number of days prior to index date to look for codes.
#' @param time_post Number of days after index date to look for codes.
#' @param numobs Number of obesrvations required to return a value of 1.
#' @param db_open An open SQLite database connection created using RSQLite::dbConnect, to be queried.
#' @param db Name of SQLITE database on hard disk (stored in "data/sql/"), to be queried.
#' @param db_filepath Full filepath to SQLITE database on hard disk, to be queried.
#' @param tab Table name to query in SQLite database.
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
#' This directory structure must be created in advance. `out_subdir` can be used to specify subdirectories within "data/extraction/". These options will use a default naming convention. This can be overwritten
#' using `out_filepath` to manually specify the location on the hard disk to save. Alternatively, return the data frame into the R workspace using `return_output = TRUE`
#' and then save onto the hard disk manually.
#'
#' Codelists can be specified in two ways. The first is to read the codelist into R as a character vector and then specify through the argument
#' `codelist_vector`. Codelists stored on the hard disk can also be referred to from the `codelist` argument, but require a specific underlying directory structure.
#' The codelist on the hard disk must be stored in a directory called "codelists/analysis/" relative to the working directory. The codelist must be a .csv file, and
#' contain a column "medcodeid", "prodcodeid" or "ICD10" depending on the input for argument `tab`. The input to argument `codelist` should just be a character string of
#' the name of the files (excluding the suffix '.csv'). The `codelist_vector` option will take precedence over the `codelist` argument if both are specified.
#'
#' @returns A data frame with a 0/1 vector and patid. 1 = presence of code within the specified time period.
#'
#' @examples
#'
#' ## Connect
#' aurum_extract <- connect_database(tempfile("temp.sqlite"))
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
#' ## Extract a history of type variable prior to index date
#' extract_ho(pat,
#' codelist_vector = "187341000000114",
#' indexdt = "fup_start",
#' db_open = aurum_extract,
#' tab = "observation",
#' return_output = TRUE)
#'
#' @export
extract_ho <- function(cohort,
                       varname = NULL,
                       codelist = NULL,
                       codelist_vector = NULL,
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
                       out_save_disk = FALSE,
                       out_subdir = NULL,
                       out_filepath = NULL,
                       return_output = TRUE){

  #       varname = "ho_ra_test10"
  #       codelist = "edh_ra_medcodeid"
  #       cohort = cohortA
  #       indexdt = "fup_start"
  #       t = NULL
  #       db = "aurum_nosubset_randset"
  #       db_filepath = NULL
  #       out_save_disk = TRUE
  #       out_filepath = NULL
  #       out_subdir = NULL
  #       return_output = TRUE
  # cohort <- pat
  # codelist = NULL
  # codelist_vector = "187341000000114"
  # indexdt = "fup_start"
  # db_open = aurum_extract
  # db = NULL
  # db_filepath = NULL
  # tab = "observation"
  # t <- NULL
  ### Preparation
  ## Add index date variable to cohort and change indexdt based on t
  cohort <- prep_cohort(cohort, indexdt, t)
  ## Assign variable name if unspecified
  if (is.null(varname)){
    varname <- "ho"
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
                     tab = tab,
                     codelist_vector = codelist_vector)

  ### Assign query_type
  if (tab == "observation"){
    query_type <- "med"
  } else if (tab == "drugissue"){
    query_type <- "drug"
  }

  ### Identify which individuals have a history of XXX
  cohort[,"ho"] <- combine_query_boolean(db_query = db.qry,
                                         cohort = cohort,
                                         query_type = query_type,
                                         time_prev = time_prev,
                                         time_post = time_post,
                                         numobs = numobs)

  ### Reduce to variables of interest
  variable_dat <- cohort[,c("patid", "ho")]

  ### Change name of variable to varname
  colnames(variable_dat)[colnames(variable_dat) == "ho"] <- varname

  ### Implement output
  implement_output(variable_dat, varname, out_save_disk, out_subdir, out_filepath, return_output)

}
