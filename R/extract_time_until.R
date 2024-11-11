#' Extract a 'time until' type variable
#'
#' @description
#' Query an RSQLite database and a data frame with the time until first code of interest or censoring, and an event/censoring indicator.
#'
#' @param cohort Cohort of individuals to extract the variable for.
#' @param varname_time Name of time variable in the outputted data frame.
#' @param varname_indicator Name of event/censoring indicator in the outputted data frame.
#' @param codelist Name of codelist (stored on hard disk) to query the database with.
#' @param codelist_vector Vector of codes to query the database with. This takes precedent over `codelist` if both are specified.
#' @param indexdt Name of variable in `cohort` which specifies the index date. The extracted variable will be calculated relative to this.
#' @param censdt Name of variable in `cohort` which specifies the censoring date.
#' @param censdt_lag Number of days after censoring where events will still be considered, to account for delays in recording.
#' @param t Number of days after \code{indexdt} at which to extract the variable.
#' @param t_varname Whether to alter the variable name in the outputted data frame to reflect `t`.
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
#' This directory structure must be created in advance. `out_subdir` can be used to specify subdirectories within "data/extraction/". These options will use a default naming convetion. This can be overwritten
#' using `out_filepath` to manually specify the location on the hard disk to save. Alternatively, return the data frame into the R workspace using `return_output = TRUE`
#' and then save onto the hard disk manually.
#'
#' Codelists can be specified in two ways. The first is to read the codelist into R as a character vector and then specify through the argument
#' `codelist_vector`. Codelists stored on the hard disk can also be referred to from the `codelist` argument, but require a specific underlying directory structure.
#' The codelist on the hard disk must be stored in a directory called "codelists/analysis/" relative to the working directory. The codelist must be a .csv file, and
#' contain a column "medcodeid", "prodcodeid" or "ICD10" depending on the input for argument `tab`. The input to argument `codelist` should just be a character string of
#' the name of the files (excluding the suffix '.csv'). The `codelist_vector` option will take precedence over the `codelist` argument if both are specified.
#'
#' If the time until event is the same as time until censored, this will be considered an event (var_indicator = 1)
#'
#' If `dtcens.lag > 0`, then the time until the event of interest will be the time until the minimum of the event of interest, and date of censoring.
#'
#' @returns A data frame with variable patid, a variable containing the time until event/censoring, and a variable containing event/censoring indicator.
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
#' ## Define cohort and add index date and censoring date
#' pat<-extract_cohort(system.file("aurum_data", package = "rcprd"))
#' pat$indexdt <- as.Date("01/01/1955", format = "%d/%m/%Y")
#' pat$fup_end <- as.Date("01/01/2000", format = "%d/%m/%Y")
#'
#' ## Extract time until event/censoring
#' extract_time_until(pat,
#' codelist_vector = "187341000000114",
#' indexdt = "fup_start",
#' censdt = "fup_end",
#' db_open = aurum_extract,
#' tab = "observation",
#' return_output = TRUE)
#'
#' ## clean up
#' RSQLite::dbDisconnect(aurum_extract)
#' unlink(file.path(tempdir(), "temp.sqlite"))
#'
#' @export
extract_time_until <- function(cohort,
                               varname_time = NULL,
                               varname_indicator = NULL,
                               codelist = NULL,
                               codelist_vector = NULL,
                               indexdt,
                               censdt,
                               censdt_lag = 0,
                               t = NULL,
                               t_varname = TRUE,
                               db_open = NULL,
                               db = NULL,
                               db_filepath = NULL,
                               tab = c("observation", "drugissue", "hes_primary", "death"),
                               out_save_disk = FALSE,
                               out_subdir = NULL,
                               out_filepath = NULL,
                               return_output = FALSE){

  #         varname_time = NULL
  #         varname_indicator = NULL
  #         codelist = "edh_cvd_hist_medcodeid"
  #         cohort = cohortZ
  #         indexdt = "fup_start"
  #         t = NULL
  #         db = "aurum_small"
  #         tab = "obs"
  #         db_filepath = NULL
  #         out_save_disk = TRUE
  #         out_filepath = NULL
  #         out_subdir = NULL
  #         return_output = TRUE

  # cohort = pat
  # varname_time = NULL
  # varname_indicator = NULL
  # codelist_vector = codelist
  # indexdt = "fup_start"
  # censdt = "fup_end"
  # db_open = aurum_extract3
  # tab = "observation"
  # return_output = TRUE
  #         db_filepath = NULL
  #         out_save_disk = FALSE
  #         out_filepath = NULL
  #         out_subdir = NULL

  ### Preparation
  ## Add index date variable to cohort and change indexdt based on t
  cohort <- prep_cohort(cohort, indexdt, t, reduce = FALSE)
  ### Change name of censoring date variable to "censdt" so we can easily refer to it
  colnames(cohort)[colnames(cohort) == censdt] <- "censdt"

  ## Reduce cohort to variables of interest
  cohort <- cohort[,c("patid", "indexdt", "censdt")]
  ## Assign variable name if unspecified
  if (is.null(varname_time)){
    varname_time <- "var_time"
  }
  if (is.null(varname_indicator)){
    varname_indicator <- "var_indicator"
  }

  ## Change variable name based off time point specified for extraction
  varname_time <- prep_varname(varname_time, t, t_varname)
  varname_indicator <- prep_varname(varname_indicator, t, t_varname)

  ## Create named subdirectory if it doesn't exist
  prep_subdir(out_subdir)

  ### Run a database query
  db.qry <- db_query(codelist,
                     db_open = db_open,
                     db = db,
                     db_filepath = db_filepath,
                     tab = tab,
                     codelist_vector = codelist_vector)

  ### Identify the first CVD event happening after the indexdt
  ## If tab = "observation", this could be a query_type of "med" or "test", choose "med" as not interested in test results themselves
  ### Assign query_type
  if (tab == "observation"){
    query_type <- "med"
  } else if (tab == "drugissue"){
    query_type <- "drug"
  }

  ## Combine query
  ## reduce_output = FALSE because we want access to censdt and
  variable_dat <- combine_query(db_query = db.qry,
                                cohort = cohort,
                                query_type = query_type,
                                time_prev = 0,
                                time_post = Inf,
                                numobs = 1,
                                value_na_rm = FALSE,
                                earliest_values = TRUE,
                                reduce_output = FALSE)

  ### Calculate the time until event of interest, set to NA and remove if beyond censdt
  variable_dat <-
    dplyr::mutate(variable_dat,
                  var_time = dplyr::case_when(obsdate <= censdt + censdt_lag ~ pmin(obsdate, censdt) - as.numeric(indexdt),
                                              obsdate > censdt + censdt_lag ~ NA),
                  var_indicator = dplyr::case_when(!is.na(var_time) ~ 1,
                                                   TRUE ~ NA)) |>
    dplyr::filter(!is.na(var_time))

  ### Reduce to variables of interst
  variable_dat <- variable_dat[,c("patid", "var_time", "var_indicator")]

  ### Merge back with cohort
  variable_dat <- merge(dplyr::select(cohort, patid, indexdt, censdt), variable_dat, by.x = "patid", by.y = "patid", all.x = TRUE)

  ### If the event has NA, set the time to censdt, and indicator to 0
  variable_dat <- dplyr::mutate(variable_dat,
                                var_indicator = dplyr::case_when(!is.na(var_time) ~ var_indicator,
                                                                 is.na(var_time) ~ 0),
                                var_time = dplyr::case_when(!is.na(var_time) ~ var_time,
                                                            is.na(var_time) ~ as.numeric(censdt - indexdt))
  )

  ### Reduce to variables of interest
  variable_dat <- variable_dat[,c("patid", "var_time", "var_indicator")]

  ### Change name of variable to varname
  colnames(variable_dat)[colnames(variable_dat) == "var_time"] <- varname_time
  colnames(variable_dat)[colnames(variable_dat) == "var_indicator"] <- varname_indicator

  ### Implement output
  implement_output(variable_dat, varname_time, out_save_disk, out_subdir, out_filepath, return_output)

}
