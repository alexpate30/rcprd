#' Extract most recent BMI score relative to an index date.
#'
#' @description
#' Extract most recent BMI score relative to an index date.
#'
#' @param cohort Cohort to extract age for.
#' @param varname Optional name for variable in output dataset.
#' @param codelist_bmi Name of codelist (stored on hard disk in "codelists/analysis/") for BMI to query the database with.
#' @param codelist_weight Name of codelist (stored on hard disk in "codelists/analysis/") for weight to query the database with.
#' @param codelist_height Name of codelist (stored on hard disk in "codelists/analysis/") for height to query the database with.
#' @param codelist_bmi_vector Vector of codes for BMI to query the database with.
#' @param codelist_weight_vector Vector of codes for weight to query the database with.
#' @param codelist_height_vector Vector of codes for height to query the database with.
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
#' @param out_save_disk If `TRUE` will attempt to save outputted data frame to directory "data/extraction/".
#' @param out_subdir Sub-directory of "data/extraction/" to save outputted data frame into.
#' @param out_filepath Full filepath and filename to save outputted data frame into.
#' @param return_output If `TRUE` will return outputted data frame into R workspace.
#'
#' @details BMI can either be identified through a directly recorded BMI score, or calculated via height and weight scores.
#' Full details on the algorithm for extracting BMI are given in the vignette: Details-on-algorithms-for-extracting-specific-variables.
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
#' @returns A data frame with variable BMI.
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
#' ## Extract most recent BMI prior to index date
#' extract_bmi(cohort = pat,
#' codelist_bmi_vector = "498521000006119",
#' codelist_weight_vector = "401539014",
#' codelist_height_vector = "13483031000006114",
#' indexdt = "indexdt",
#' time_prev = Inf,
#' db_open = aurum_extract,
#' return_output = TRUE)
#'
#' @export
extract_bmi <- function(cohort,
                        varname = NULL,
                        codelist_bmi = NULL,
                        codelist_weight = NULL,
                        codelist_height = NULL,
                        codelist_bmi_vector = NULL,
                        codelist_weight_vector = NULL,
                        codelist_height_vector = NULL,
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
                        out_save_disk = FALSE,
                        out_subdir = NULL,
                        out_filepath = NULL,
                        return_output = TRUE){

          # varname = NULL
          # cohort = cohortZ
          # codelist_bmi = "edh_bmi_medcodeid"
          # codelist_height = "height_medcodeid"
          # codelist_weight = "weight_medcodeid"
          # indexdt = "fup_start"
          # t = 0
          # t_varname = TRUE
          # time_prev = round(365.25*5)
          # time_post = 0
          # lower_bound = 18
          # upper_bound = 47
          # db = "aurum_small"
          # db_filepath = NULL
          # out_save_disk = FALSE
          # out_filepath = NULL
          # out_subdir = NULL
          # return_output = TRUE
          #
          #
          # codelist_bmi_vector = 498521000006119
          # codelist_weight_vector = 401539014
          # codelist_height_vector = 13483031000006114
          # indexdt = "indexdt"
          # time_prev = Inf
          # time_post = Inf
          # db_open = aurum_extract
          # return_output = TRUE
  ### ADD TEST TO ENSURE THEY SPECIFY TIME FRAME


  ### Preparation
  ## Add index date variable to cohort and change indexdt based on t
  cohort <- prep_cohort(cohort, indexdt, t)
  ## Assign variable name if unspecified
  if (is.null(varname)){
    varname <- "bmi"
  }
  ## Change variable name based off time point specified for extraction
  varname <- prep_varname(varname, t, t_varname)
  ## Create named subdirectory if it doesn't exist
  prep_subdir(out_subdir)

  ### Need to run three database queries, one for BMI, one for height and one for weight
  ### BMI
  db.qry.bmi <- db_query(codelist_bmi,
                         db_open = db_open,
                         db = db,
                         db_filepath = db_filepath,
                         tab = "observation",
                         codelist_vector = codelist_bmi_vector)

  variable_dat.bmi <- combine_query(db_query = db.qry.bmi,
                                    cohort = cohort,
                                    query_type = "test",
                                    time_prev = time_prev,
                                    time_post = time_post,
                                    lower_bound = lower_bound,
                                    upper_bound = upper_bound)

  ### Height
  db.qry.height <- db_query(codelist_height,
                            db_open = db_open,
                            db = db,
                            db_filepath = db_filepath,
                            tab = "observation",
                            codelist_vector = codelist_height_vector)

  variable_dat.height <- combine_query(db_query = db.qry.height,
                                       cohort = cohort,
                                       query_type = "test",
                                       time_prev = time_prev,
                                       time_post = time_post)

  ### Weight
  db.qry.weight <- db_query(codelist_weight,
                            db_open = db_open,
                            db = db,
                            db_filepath = db_filepath,
                            tab = "observation",
                            codelist_vector = codelist_weight_vector)

  variable_dat.weight <- combine_query(db_query = db.qry.weight,
                                       cohort = cohort,
                                       query_type = "test",
                                       time_prev = time_prev,
                                       time_post = time_post)

  ### For the height query, we need to rescale those without numunitid = 173, 432 or 3202 from cm to m
  variable_dat.height <- dplyr::mutate(variable_dat.height, value = dplyr::case_when(numunitid %in% c(173, 432, 3202) ~ value,
                                                                         !(numunitid %in% c(173, 432, 3202)) ~ value/100))
  ### For the weight query, we need to rescale those with numunitid = 1691, 2318, 2997 or 6265 from stone to kg
  variable_dat.weight <- dplyr::mutate(variable_dat.weight, value = dplyr::case_when(numunitid %in% c(1691, 2318, 2997, 6265) ~ 6.35029*value,
                                                                         !(numunitid %in% c(1691, 2318, 2997, 6265)) ~ value))

  ### Calculate bmi's estimated from height/weight
  ## Merge height and weight datasets
  variable_dat.manual <- merge(variable_dat.weight, variable_dat.height, by.x = "patid", by.y = "patid")
  ## Calculate bmi
  variable_dat.manual$value <- variable_dat.manual$value.x/(variable_dat.manual$value.y)^2
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
  rm(variable_dat.height, variable_dat.weight)

  ### Merge the two
  variable_dat <- merge(variable_dat.bmi, variable_dat.manual, by.x = "patid", by.y = "patid", all.x = TRUE, all.y = TRUE)

  ### Take most recent of the two
  variable_dat <- dplyr::mutate(variable_dat, bmi = dplyr::case_when(is.na(value.x) & !is.na(value.y) ~ value.y,
                                                                     !is.na(value.x) & is.na(value.y) ~ value.x,
                                                                     !is.na(value.x) & !is.na(value.y) & obsdate.y > obsdate.x ~ value.y,
                                                                     !is.na(value.x) & !is.na(value.y) & obsdate.y <= obsdate.x ~ value.x))

  ### Create dataframe of cohort and the variable of interest
  variable_dat <- merge(dplyr::select(cohort, patid), variable_dat, by.x = "patid", by.y = "patid", all.x = TRUE)

  ### Reduce to variables of interest
  variable_dat <- variable_dat[,c("patid", "bmi")]

  ### Change name of variable to varname
  colnames(variable_dat)[colnames(variable_dat) == "bmi"] <- varname

  ### Implement output
  implement_output(variable_dat, varname, out_save_disk, out_subdir, out_filepath, return_output)

}
