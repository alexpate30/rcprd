#' Extract diabetes status prior to an index date.
#'
#' @description
#' Extract diabetes status prior to an index date.
#'
#' @param cohort Cohort to extract age for.
#' @param varname Optional name for variable in output dataset.
#' @param codelist_type1 Name of codelist (stored on hard disk in "codelists/analysis/") for type 1 diabetes to query the database with.
#' @param codelist_type2 Name of codelist (stored on hard disk in "codelists/analysis/") for type 2 diabetes to query the database with.
#' @param codelist_type1_vector Vector of codes for type 1 diabetes to query the database with.
#' @param codelist_type2_vector Vector of codes for type 2 diabetes to query the database with.
#' @param indexdt Name of variable which defines index date in `cohort`.
#' @param t Number of days after index date at which to calculate variable.
#' @param t_varname Whether to add `t` to `varname`.
#' @param db_open An open SQLite database connection created using RSQLite::dbConnect, to be queried.
#' @param db Name of SQLITE database on hard disk (stored in "data/sql/"), to be queried.
#' @param db_filepath Full filepath to SQLITE database on hard disk, to be queried.
#' @param out_save_disk If `TRUE` will attempt to save outputted data frame to directory "data/extraction/".
#' @param out_subdir Sub-directory of "data/extraction/" to save outputted data frame into.
#' @param out_filepath Full filepath and filename to save outputted data frame into.
#' @param return_output If `TRUE` will return outputted data frame into R workspace.
#'
#' @details If an individual is found to have medical codes for both type 1 and type 2 diabetes, the returned value of diabetes status will be type 1 diabetes.
#' Full details on the algorithm for extracting diabetes status are given in the vignette: Details-on-algorithms-for-extracting-specific-variables.
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
#' @returns A data frame with variable diabetes status.
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
#' ## Extract diabetes prior to index date
#' extract_diabetes(cohort = pat,
#' codelist_type1_vector = "498521000006119",
#' codelist_type2_vector = "401539014",
#' indexdt = "indexdt",
#' db_open = aurum_extract)
#'
#' @export
extract_diabetes <- function(cohort,
                             varname = NULL,
                             codelist_type1 = NULL,
                             codelist_type2 = NULL,
                             codelist_type1_vector = NULL,
                             codelist_type2_vector = NULL,
                             indexdt,
                             t = NULL,
                             t_varname = TRUE,
                             db_open = NULL,
                             db = NULL,
                             db_filepath = NULL,
                             out_save_disk = FALSE,
                             out_subdir = NULL,
                             out_filepath = NULL,
                             return_output = TRUE){

  #         varname = NULL
  #         codelist_type1 = "edh_t1dia_medcodeid"
  #         codelist_type2 = "edh_t2dia_medcodeid"
  #         cohort = cohortZ
  #         indexdt = "fup_start"
  #         t = NULL
  #         db = "aurum_small"
  #         db_filepath = NULL
  #         out_save_disk = TRUE
  #         out_filepath = NULL
  #         out_subdir = NULL
  #         return_output = TRUE

  ### Preparation
  ## Add index date variable to cohort and change indexdt based on t
  cohort <- prep_cohort(cohort, indexdt, t)
  ## Assign variable name if unspecified
  if (is.null(varname)){
    varname <- "diabetes"
  }
  ## Change variable name based off time point specified for extraction
  varname <- prep_varname(varname, t, t_varname)
  ## Create named subdirectory if it doesn't exist
  prep_subdir(out_subdir)

  ### Run a database query for type 1 and type 2
  db.qry.type1 <- db_query(codelist_type1,
                           db_open = db_open,
                           db = db,
                           db_filepath = db_filepath,
                           tab = "observation",
                           codelist_vector = codelist_type1_vector)

  db.qry.type2 <- db_query(codelist_type2,
                           db_open = db_open,
                           db = db,
                           db_filepath = db_filepath,
                           tab = "observation",
                           codelist_vector = codelist_type2_vector)

  ### Identify which individuals have a history of type 1 or type 2
  cohort[,"t1dia"] <- combine_query_boolean(db_query = db.qry.type1,
                                            cohort = cohort,
                                            query_type = "med")

  cohort[,"t2dia"] <- combine_query_boolean(db_query = db.qry.type2,
                                            cohort = cohort,
                                            query_type = "med")

  ### Create the varaible of interest from these
  ### if an individual has history of type 1 and type 2, they will be classed as type 1
  variable_dat <- dplyr::mutate(cohort, diabetes = dplyr::case_when(t2dia == 0 & t1dia == 0 ~ 0,
                                                                    t1dia == 1 ~ 1,
                                                                    t2dia == 1 ~ 2))

  ### Turn into factor variable
  variable_dat$diabetes <- factor(variable_dat$diabetes,
                                  levels = c(0,1,2),
                                  labels = c("Absent", "Type1", "Type2"))

  ### Reduce to variables of interest
  variable_dat <- variable_dat[,c("patid", "diabetes")]

  ### Change name of variable to varname
  colnames(variable_dat)[colnames(variable_dat) == "diabetes"] <- varname

  ### Implement output
  implement_output(variable_dat, varname, out_save_disk, out_subdir, out_filepath, return_output)

}
