#' Extract smoking status prior to index date.
#'
#' @description
#' Extract smoking status prior to index date.
#'
#' @param cohort Cohort to extract age for.
#' @param varname Optional name for variable in output dataset.
#' @param codelist_non Name of codelist (stored on hard disk in "codelists/analysis/") for non-smoker to query the database with.
#' @param codelist_ex Name of codelist (stored on hard disk in "codelists/analysis/") for ex-smoker to query the database with.
#' @param codelist_light Name of codelist (stored on hard disk in "codelists/analysis/") for light smoker to query the database with.
#' @param codelist_mod Name of codelist (stored on hard disk in "codelists/analysis/") for moderate smoker to query the database with.
#' @param codelist_heavy Name of codelist (stored on hard disk in "codelists/analysis/") for heavy smoker to query the database with.
#' @param codelist_non_vector Vector of codes for non-smoker to query the database with.
#' @param codelist_ex_vector Vector of codes for ex-smoker to query the database with.
#' @param codelist_light_vector Vector of codes for light smoker to query the database with.
#' @param codelist_mod_vector Vector of codes for moderate smoker to query the database with.
#' @param codelist_heavy_vector Vector of codes for heavy smoker to query the database with.
#' @param codelist_non_df data.frame of codes for non-smoker to query the database with.
#' @param codelist_ex_df data.frame of codes for ex-smoker to query the database with.
#' @param codelist_light_df data.frame of codes for light smoker to query the database with.
#' @param codelist_mod_df data.frame of codes for moderate smoker to query the database with.
#' @param codelist_heavy_df data.frame of codes for heavy smoker to query the database with.
#' @param indexdt Name of variable which defines index date in `cohort`.
#' @param t Number of days after index date at which to calculate variable.
#' @param t_varname Whether to add `t` to `varname`.
#' @param db_open An open SQLite database connection created using RSQLite::dbConnect, to be queried.
#' @param db Name of SQLITE database on hard disk (stored in "data/sql/"), to be queried.
#' @param db_filepath Full filepath to SQLITE database on hard disk, to be queried.
#' @param table_name Specify name of table in the SQLite database to be queried, if this is different from 'observation'.
#' @param out_save_disk If `TRUE` will attempt to save outputted data frame to directory "data/extraction/".
#' @param out_subdir Sub-directory of "data/extraction/" to save outputted data frame into.
#' @param out_filepath Full filepath and filename to save outputted data frame into.
#' @param return_output If `TRUE` will return outputted data frame into R workspace.
#'
#' @details Returns the most recent value of smoking status. If the most recently recorded observation of smoking status is non-smoker, but the individual
#' has a history of smoking identified through the medical record, the outputted value of smoking status will be ex-smoker.
#' Full details on the algorithm for extracting smoking status are given in the vignette: Details-on-algorithms-for-extracting-specific-variables.
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
#' We take the most recent smoking status record. If an individuals most recent smoking status is a non-smoker,
#' but they have a history of smoking prior to this, these individuals will be classed as ex-smokers.
#'
#' The argument `table_name` is only necessary if the name of the table being queried does not match 'observation'. This will occur when
#' `str_match` is used in `cprd_extract` or `add_to_database` to create the .sqlite database.
#'
#' @returns A data frame with variable smoking status.
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
#' ## Extract smoking status prior to index date
#' extract_smoking(cohort = pat,
#' codelist_non_vector = "498521000006119",
#' codelist_ex_vector = "401539014",
#' codelist_light_vector = "128011000000115",
#' codelist_mod_vector = "380389013",
#' codelist_heavy_vector = "13483031000006114",
#' indexdt = "indexdt",
#' db_open = aurum_extract)
#'
#' ## clean up
#' RSQLite::dbDisconnect(aurum_extract)
#' unlink(file.path(tempdir(), "temp.sqlite"))
#'
#' @export
#'
extract_smoking <- function(cohort,
                            varname = NULL,
                            codelist_non = NULL,
                            codelist_ex = NULL,
                            codelist_light = NULL,
                            codelist_mod = NULL,
                            codelist_heavy = NULL,
                            codelist_non_vector = NULL,
                            codelist_ex_vector = NULL,
                            codelist_light_vector = NULL,
                            codelist_mod_vector = NULL,
                            codelist_heavy_vector = NULL,
                            codelist_non_df = NULL,
                            codelist_ex_df = NULL,
                            codelist_light_df = NULL,
                            codelist_mod_df = NULL,
                            codelist_heavy_df = NULL,
                            indexdt,
                            t = NULL,
                            t_varname = TRUE,
                            db_open = NULL,
                            db = NULL,
                            db_filepath = NULL,
                            table_name = NULL,
                            out_save_disk = FALSE,
                            out_subdir = NULL,
                            out_filepath = NULL,
                            return_output = TRUE){

  #   varname = NULL
  #   codelist_non = "edh_smoking_non_medcodeid"
  #   codelist_ex = "edh_smoking_ex_medcodeid"
  #   codelist_light = "edh_smoking_light_medcodeid"
  #   codelist_mod = "edh_smoking_mod_medcodeid"
  #   codelist_heavy = "edh_smoking_heavy_medcodeid"
  #   cohort = cohortZ
  #   indexdt = "fup_start"
  #   t = NULL
  #   db = "aurum_small"
  #   db_filepath = NULL
  #   out_save_disk = TRUE
  #   out_filepath = NULL
  #   out_subdir = NULL
  #   return_output = TRUE

  ### Preparation
  ## Add index date variable to cohort and change indexdt based on t
  cohort <- prep_cohort(cohort, indexdt, t)
  ## Assign variable name if unspecified
  if (is.null(varname)){
    varname <- "smoking"
  }
  ## Change variable name based off time point specified for extraction
  varname <- prep_varname(varname, t, t_varname)
  ## Create named subdirectory if it doesn't exist
  prep_subdir(out_subdir)

  ### Run a database query for type 1 and type 2
  db.qry.non <- db_query(codelist_non,
                         db_open = db_open,
                         db = db,
                         db_filepath = db_filepath,
                         tab = "observation",
                         table_name = table_name,
                         codelist_vector = codelist_non_vector,
                         codelist_df = codelist_non_df)

  db.qry.ex <- db_query(codelist_ex,
                        db_open = db_open,
                        db = db,
                        db_filepath = db_filepath,
                        tab = "observation",
                        table_name = table_name,
                        codelist_vector = codelist_ex_vector,
                        codelist_df = codelist_ex_df)

  db.qry.light <- db_query(codelist_light,
                           db_open = db_open,
                           db = db,
                           db_filepath = db_filepath,
                           tab = "observation",
                           table_name = table_name,
                           codelist_vector = codelist_light_vector,
                           codelist_df = codelist_light_df)

  db.qry.mod <- db_query(codelist_mod,
                         db_open = db_open,
                         db = db,
                         db_filepath = db_filepath,
                         tab = "observation",
                         table_name = table_name,
                         codelist_vector = codelist_mod_vector,
                         codelist_df = codelist_mod_df)

  db.qry.heavy <- db_query(codelist_heavy,
                           db_open = db_open,
                           db = db,
                           db_filepath = db_filepath,
                           tab = "observation",
                           table_name = table_name,
                           codelist_vector = codelist_heavy_vector,
                           codelist_df = codelist_heavy_df)

  ### Combine queries with cohort, retaining all smoking records prior to the index date
  ### We treat this as test data, because smoking status may be identified through number of cigarettes smoked per day
  ### We specify value_na_rm = FALSE, as we want to keep the NA values, because smoking status can also be identified through
  ### the medcodeid itself.
  smoking.non <- combine_query(db_query = db.qry.non,
                               cohort= cohort,
                               query_type = "test",
                               numobs = Inf,
                               value_na_rm = FALSE)

  smoking.ex <- combine_query(db_query = db.qry.ex,
                              cohort = cohort,
                              query_type = "test",
                              numobs = Inf,
                              value_na_rm = FALSE)

  smoking.light <- combine_query(db_query = db.qry.light,
                                 cohort = cohort,
                                 query_type = "test",
                                 numobs = Inf,
                                 value_na_rm = FALSE)

  smoking.mod <- combine_query(db_query = db.qry.mod,
                               cohort = cohort,
                               query_type = "test",
                               numobs = Inf,
                               value_na_rm = FALSE)

  smoking.heavy <- combine_query(db_query = db.qry.heavy,
                                 cohort = cohort,
                                 query_type = "test",
                                 numobs = Inf,
                                 value_na_rm = FALSE)

  ### Currently heavy and moderate have no number of cigarettes smoked per day data
  ### Light smoker has lots of data on this, as the codes actually include "light or not stated"
  ### Ex smoker contains lots of values, but cannot be used as looks like they are either used to state
  ### how many a day used to be smoked, or the year at which smoking was given up.
  ### Non-smoker currently has no values bigger than zero
  #   sum(!is.na(smoking.heavy$value))
  #   sum(!is.na(smoking.mod$value))
  #   sum(!is.na(smoking.light$value))
  #   sum(!is.na(smoking.non$value) & smoking.non$value > 0)
  #   sum(!is.na(smoking.ex$value) & smoking.ex$value > 0)

  ### Add the smoking variable to each dataset
  ### Assign a smoking value (0 = non, 1 = ex, 2 = light, 3 = moderate, 4 = heavy) to every observation in each query,
  ### defined solely by the code lists and medical codes
  smoking.non$smoking <- 0
  smoking.ex$smoking <- 1
  smoking.light$smoking <- 2
  smoking.mod$smoking <- 3
  smoking.heavy$smoking <- 4

  ### Change smoking depending on the test value for smoking.light, smoking.mod and smoking.heavy
  ### We set to NA if more than 100
  smoking.light <- dplyr::mutate(smoking.light,
                                 smoking = dplyr::case_when(is.na(value) ~ smoking,
                                                            value == 0 ~ 0,
                                                            value > 0 & value < 10 ~ 2,
                                                            value >= 10 & value < 20 ~ 3,
                                                            value >= 20 & value <= 100 ~ 4,
                                                            value > 100 ~ NA)
  )

  smoking.mod <- dplyr::mutate(smoking.mod,
                               smoking = dplyr::case_when(is.na(value) ~ smoking,
                                                          value == 0 ~ 0,
                                                          value > 0 & value < 10 ~ 2,
                                                          value >= 10 & value < 20 ~ 3,
                                                          value >= 20 & value <= 100 ~ 4,
                                                          value > 100 ~ NA)
  )

  smoking.heavy <- dplyr::mutate(smoking.heavy,
                                 smoking = dplyr::case_when(is.na(value) ~ smoking,
                                                            value == 0 ~ 0,
                                                            value > 0 & value < 10 ~ 2,
                                                            value >= 10 & value < 20 ~ 3,
                                                            value >= 20 & value <= 100 ~ 4,
                                                            value > 100 ~ NA)
  )

  ### Remove the NA values
  smoking.light <- smoking.light[!is.na(smoking)]
  smoking.mod <- smoking.mod[!is.na(smoking)]
  smoking.heavy <- smoking.heavy[!is.na(smoking)]

  ### Only retain the most recent observation for each
  smoking.non <- smoking.non |>
    dplyr::group_by(patid) |>
    dplyr::filter(dplyr::row_number(dplyr::desc(obsdate)) == 1)

  smoking.ex <- smoking.ex |>
    dplyr::group_by(patid) |>
    dplyr::filter(dplyr::row_number(dplyr::desc(obsdate)) == 1)

  smoking.light <- smoking.light |>
    dplyr::group_by(patid) |>
    dplyr::filter(dplyr::row_number(dplyr::desc(obsdate)) == 1)

  smoking.mod <- smoking.mod |>
    dplyr::group_by(patid) |>
    dplyr::filter(dplyr::row_number(dplyr::desc(obsdate)) == 1)

  smoking.heavy <- smoking.heavy |>
    dplyr::group_by(patid) |>
    dplyr::filter(dplyr::row_number(dplyr::desc(obsdate)) == 1)

  ### Concatenate
  variable_dat <- rbind(smoking.non, smoking.ex, smoking.light, smoking.mod, smoking.heavy)

  ### Arrange so that the first observation is the most recent
  ### If there are multiple on the same day, we take the most severe smoking status
  variable_dat <-variable_dat |>
    dplyr::arrange(patid, dplyr::desc(obsdate), dplyr::desc(smoking)) |>
    dplyr::group_by(patid)

  ### Identify those with a smoking history. Given we have only retained one observations from each category,
  ### this means this individual with > 1 observation must have some sort of smoking history.
  smoking.history <- variable_dat |>
    dplyr::summarise(count = dplyr::n()) |>
    dplyr::filter(count > 1) |>
    dplyr::select(patid) |>
    dplyr::mutate(smoking.history = 1)

  ### Reduce variable_dat to most recent observation only
  variable_dat <- dplyr::slice(variable_dat, 1)

  ### If their most recent value is non-smoker and they have a smoking history, we must change non-smoker to ex-smoker.
  variable_dat <- merge(variable_dat, smoking.history, all.x = TRUE)
  variable_dat <- dplyr::mutate(variable_dat,
                                smoking = dplyr::case_when(smoking == 0 & !is.na(smoking.history) ~ 1,
                                                           TRUE ~ smoking))
  ### Turn into factor variable
  variable_dat$smoking <- factor(variable_dat$smoking,
                                 levels = c(0,1,2,3,4),
                                 labels = c("Non-smoker", "Ex-smoker", "Light", "Moderate", "Heavy"))

  ### Create dataframe of cohort and the variable of interest
  variable_dat <- merge(dplyr::select(cohort, patid), variable_dat, by.x = "patid", by.y = "patid", all.x = TRUE)

  ### Reduce to variables of interest
  variable_dat <- variable_dat[,c("patid", "smoking")]

  ### Change name of variable to varname
  colnames(variable_dat)[colnames(variable_dat) == "smoking"] <- varname

  ### Implement output
  implement_output(variable_dat, varname, out_save_disk, out_subdir, out_filepath, return_output)

}
