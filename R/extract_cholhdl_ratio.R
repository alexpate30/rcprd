#' Extract most recent total cholesterol/high-density lipoprotein ratio score relative to an index date.
#'
#' @description
#' Extract most recent total cholesterol/high-density lipoprotein ratio score relative to an index date.
#'
#' @param cohort Cohort to extract age for.
#' @param varname Optional name for variable in output dataset.
#' @param codelist_ratio Name of codelist (stored on hard disk in "codelists/analysis/") for ratio to query the database with.
#' @param codelist_chol Name of codelist (stored on hard disk in "codelists/analysis/") for total cholesterol to query the database with.
#' @param codelist_hdl Name of codelist (stored on hard disk in "codelists/analysis/") for high-density lipoprotein to query the database with.
#' @param codelist_ratio_vector Vector of codes for ratio to query the database with.
#' @param codelist_chol_vector Vector of codes for total cholesterol to query the database with.
#' @param codelist_hdl_vector Vector of codes for high-density lipoprotein to query the database with.
#' @param indexdt Name of variable which defines index date in `cohort`.
#' @param t Number of days after index date at which to calculate variable.
#' @param t_varname Whether to add `t` to `varname`.
#' @param time_prev Number of days prior to index date to look for codes.
#' @param time_post Number of days after index date to look for codes.
#' @param lower_bound Lower bound for returned values.
#' @param upper_bound Upper bound for returned values.
#' @param db_open An open SQLite database connection created using RSQLite::dbConnect, to be queried.
#' @param db Name of SQLITE database on hard disk (stored in "data/sql/"), to be queried.
#' @param db_filepath Full filepath to SQLITE database on hard disk, to be queried.
#' @param table_name Specify name of table in the SQLite database to be queried, if this is different from 'observation'.
#' @param out_save_disk If `TRUE` will attempt to save outputted data frame to directory "data/extraction/".
#' @param out_subdir Sub-directory of "data/extraction/" to save outputted data frame into.
#' @param out_filepath Full filepath and filename to save outputted data frame into.
#' @param return_output If `TRUE` will return outputted data frame into R workspace.
#'
#' @details Cholesterol/HDL ratio can either be identified through a directly recorded cholesterol/hdl ratio score, or calculated via total cholesterol and HDL scores.
#' Full details on the algorithm for extracting cholesterol/hdl ratio are given in the vignette: Details-on-algorithms-for-extracting-specific-variables.
#' This vignette can be viewed by running \code{vignette("help", package = "rcprd")}.
#'
#' Specifying `db` requires a specific underlying directory structure. The SQLite database must be stored in "data/sql/" relative to the working directory.
#' If the SQLite database is accessed through `db`, the connection will be opened and then closed after the query is complete. The same is true if
#' the database is accessed through `db_filepath`. A connection to the SQLite database can also be opened manually using `RSQLite::dbConnect`, and then
#' using the object as input to parameter `db_open`. After wards, the connection must be closed manually using `RSQLite::dbDisconnect`. If `db_open` is specified, this will take precedence over `db` or `db_filepath`.
#'
#' If `out_save_disk = TRUE`, the data frame will automatically be written to an .rds file in a subdirectory "data/extraction/" of the working directory.
#' This directory structure must be created in advance. `out_subdir` can be used to specify subdirectories within "data/extraction/". These options will use a default naming convetion. This can be overwritten
#' using `out_filepath` to manually specify the location on the hard disk to save. Alternatively, return the data frame into the R workspace using `return_output = TRUE`
#' and then save onto the hard disk manually.
#'
#' Specifying the non-vector type codelists requires a specific underlying directory structure. The codelist on the hard disk must be stored in "codelists/analysis/" relative
#' to the working directory, must be a .csv file, and contain a column "medcodeid", "prodcodeid" or "ICD10" depending on the chosen `tab`. The input
#' to these variables should just be the name of the files (excluding the suffix .csv). The codelists can also be read in manually, and supplied as a
#' character vector. This option will take precedence over the codelists stored on the hard disk if both are specified.
#'
#' The argument `table_name` is only necessary if the name of the table being queried does not match 'observation'. This will occur when
#' `str_match` is used in `cprd_extract` or `add_to_database` to create the .sqlite database.
#'
#' @returns A data frame with variable total cholesterol/high-density lipoprotein ratio.
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
#' ## Extract most recent cholhdl_ratio prior to index date
#' extract_cholhdl_ratio(cohort = pat,
#' codelist_ratio_vector = "498521000006119",
#' codelist_chol_vector = "401539014",
#' codelist_hdl_vector = "13483031000006114",
#' indexdt = "indexdt",
#' time_prev = Inf,
#' db_open = aurum_extract,
#' return_output = TRUE)
#'
#' ## clean up
#' RSQLite::dbDisconnect(aurum_extract)
#' unlink(file.path(tempdir(), "temp.sqlite"))
#'
#' @export
extract_cholhdl_ratio <- function(cohort,
                                  varname = NULL,
                                  codelist_ratio = NULL,
                                  codelist_chol = NULL,
                                  codelist_hdl = NULL,
                                  codelist_ratio_vector = NULL,
                                  codelist_chol_vector = NULL,
                                  codelist_hdl_vector = NULL,
                                  indexdt,
                                  t = NULL,
                                  t_varname = TRUE,
                                  time_prev = 365.25*5,
                                  time_post = 0,
                                  lower_bound = -Inf,
                                  upper_bound = Inf,
                                  db_open = NULL,
                                  db = NULL,
                                  db_filepath = NULL,
                                  table_name = NULL,
                                  out_save_disk = FALSE,
                                  out_subdir = NULL,
                                  out_filepath = NULL,
                                  return_output = TRUE){

  #           varname = NULL
  #           cohort = cohortZ
  #           codelist_ratio = "edh_cholhdl_ratio_medcodeid"
  #           codelist_chol = "edh_chol_medcodeid"
  #           codelist_hdl = "edh_hdl_medcodeid"
  #           indexdt = "fup_start"
  #           t = 0
  #           t_varname = TRUE
  #           time_prev = round(365.25*5)
  #           time_post = 0
  #           lower_bound = 1
  #           upper_bound = 12
  #           db = "aurum_nosubset_randset"
  #           db_filepath = NULL
  #           out_save_disk = FALSE
  #           out_filepath = NULL
  #           out_subdir = NULL
  #           return_output = TRUE

  ### ADD TEST TO ENSURE THEY SPECIFY TIME FRAME

  ### Preparation
  ## Add index date variable to cohort and change indexdt based on t
  cohort <- prep_cohort(cohort, indexdt, t)
  ## Assign variable name if unspecified
  if (is.null(varname)){
    varname <- "cholhdl_ratio"
  }
  ## Change variable name based off time point specified for extraction
  varname <- prep_varname(varname, t, t_varname)
  ## Create named subdirectory if it doesn't exist
  prep_subdir(out_subdir)

  ### Need to run three database queries, one for ratio, one for chol and one for hdl
  db.qry.ratio <- db_query(codelist_ratio,
                           db_open = db_open,
                           db = db,
                           db_filepath = db_filepath,
                           tab = "observation",
                           table_name = table_name,
                           codelist_vector = codelist_ratio_vector)

  db.qry.chol <- db_query(codelist_chol,
                          db_open = db_open,
                          db = db,
                          db_filepath = db_filepath,
                          tab = "observation",
                          table_name = table_name,
                          codelist_vector = codelist_chol_vector)

  db.qry.hdl <- db_query(codelist_hdl,
                         db_open = db_open,
                         db = db,
                         db_filepath = db_filepath,
                         tab = "observation",
                         table_name = table_name,
                         codelist_vector = codelist_hdl_vector)

  ### Get latest test result for ratio, chol and hdl from the last five years
  variable_dat.ratio <- combine_query(db_query = db.qry.ratio,
                                      cohort= cohort,
                                      query_type = "test",
                                      time_prev = time_prev,
                                      time_post = time_post,
                                      lower_bound = lower_bound,
                                      upper_bound = upper_bound)

  variable_dat.chol <- combine_query(db_query = db.qry.chol,
                                     cohort = cohort,
                                     query_type = "test",
                                     time_prev = time_prev,
                                     time_post = time_post)

  variable_dat.hdl <- combine_query(db_query = db.qry.hdl,
                                    cohort = cohort,
                                    query_type = "test",
                                    time_prev = time_prev,
                                    time_post = time_post)

  ### Calculate ratio's estimated from chol/hdl
  ## Merge chol and hdl datasets
  variable_dat.manual <- merge(variable_dat.chol, variable_dat.hdl, by.x = "patid", by.y = "patid")
  ## Calculate ratio
  variable_dat.manual$value <- variable_dat.manual$value.x/variable_dat.manual$value.y
  ## Take furthest away date
  variable_dat.manual$obsdate <- pmin(variable_dat.manual$obsdate.x, variable_dat.manual$obsdate.y)
  ## Remove values outside of range
  ### If values are missing, < lower_bound or > upper_bound then delete
  if (!is.null(lower_bound) & !is.null(upper_bound)){
    variable_dat.manual <- variable_dat.manual[value > lower_bound & value < upper_bound]
  } else if (is.null(lower_bound) & !is.null(upper_bound)){
    variable_dat.manual <- variable_dat.manual[value < upper_bound]
  } else if (!is.null(lower_bound) & is.null(upper_bound)){
    variable_dat.manual <- variable_dat.manual[value > lower_bound]
  }
  variable_dat.manual <- variable_dat.manual[,c("patid", "value", "obsdate")]
  rm(variable_dat.chol, variable_dat.hdl)

  ### Merge the two
  variable_dat <- merge(variable_dat.ratio, variable_dat.manual, by.x = "patid", by.y = "patid", all.x = TRUE, all.y = TRUE)

  ### Take most recent of the two
  variable_dat <- dplyr::mutate(variable_dat, cholhdl_ratio = dplyr::case_when(is.na(value.x) & !is.na(value.y) ~ value.y,
                                                                               !is.na(value.x) & is.na(value.y) ~ value.x,
                                                                               !is.na(value.x) & !is.na(value.y) & obsdate.y > obsdate.x ~ value.y,
                                                                               !is.na(value.x) & !is.na(value.y) & obsdate.y <= obsdate.x ~ value.x))

  ### Create dataframe of cohort and the variable of interest
  variable_dat <- merge(dplyr::select(cohort, patid), variable_dat, by.x = "patid", by.y = "patid", all.x = TRUE)

  ### Reduce to variables of interest
  variable_dat <- variable_dat[,c("patid", "cholhdl_ratio")]

  ### Change name of variable to varname
  colnames(variable_dat)[colnames(variable_dat) == "cholhdl_ratio"] <- varname

  ### Implement output
  implement_output(variable_dat, varname, out_save_disk, out_subdir, out_filepath, return_output)

}
