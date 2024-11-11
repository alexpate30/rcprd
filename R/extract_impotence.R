#' Extract impotence status.
#'
#' @description
#' Extract impotence status. This requires either a medical diagnosis, or `drug_numobs` number of prescriptions in `drug_time_prev` number of days
#' prior to the index date.
#'
#' @param cohort Cohort to extract age for.
#' @param varname Optional name for variable in output dataset.
#' @param codelist_med Name of codelist (stored on hard disk in "codelists/analysis/") for medical diagnoses to query the database with.
#' @param codelist_drug Name of codelist (stored on hard disk in "codelists/analysis/") for prescriptions to query the database with.
#' @param codelist_med_vector Vector of codes for medical diagnoses to query the database with.
#' @param codelist_drug_vector Vector of codes for prescriptions to query the database with.
#' @param indexdt Name of variable which defines index date in `cohort`.
#' @param t Number of days after index date at which to calculate variable.
#' @param t_varname Whether to add `t` to `varname`.
#' @param drug_time_prev Number of days prior to index date in which to look for prescriptions.
#' @param drug_numobs Numbre of prescriptions required in time period to indicate impotence.
#' @param db_open An open SQLite database connection created using RSQLite::dbConnect, to be queried.
#' @param db Name of SQLITE database on hard disk (stored in "data/sql/"), to be queried.
#' @param db_filepath Full filepath to SQLITE database on hard disk, to be queried.
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
#' Specifying the non-vector type codelists requires a specific underlying directory structure. The codelist on the hard disk must be stored in "codelists/analysis/" relative
#' to the working directory, must be a .csv file, and contain a column "medcodeid", "prodcodeid" or "ICD10" depending on the chosen `tab`. The input
#' to these variables should just be the name of the files (excluding the suffix .csv). The codelists can also be read in manually, and supplied as a
#' character vector. This option will take precedence over the codelists stored on the hard disk if both are specified.
#'
#' @returns A data frame with variable impotence status.
#'
#' @noRd
extract_impotence <- function(cohort,
                              varname = NULL,
                              codelist_med = NULL,
                              codelist_drug = NULL,
                              codelist_med_vector = NULL,
                              codelist_drug_vector = NULL,
                              indexdt,
                              t = NULL,
                              t_varname = TRUE,
                              drug_time_prev = Inf,
                              drug_numobs = 1,
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
    varname <- "impotence"
  }
  ## Change variable name based off time point specified for extraction
  varname <- prep_varname(varname, t, t_varname)
  ## Create named subdirectory if it doesn't exist
  prep_subdir(out_subdir)

  ### Run a database query for type 1 and type 2
  db.qry.med <- db_query(codelist_med,
                         db_open = db_open,
                         db = db,
                         db_filepath = db_filepath,
                         tab = "observation",
                         codelist_vector = codelist_med_vector)

  db.qry.drug <- db_query(codelist_drug,
                          db_open = db_open,
                          db = db,
                          db_filepath = db_filepath,
                          tab = "drugissue",
                          codelist_vector = codelist_drug_vector)

  ### Identify which individuals have a history of type 1 or type 2
  cohort[,"med"] <- combine_query_boolean(db_query = db.qry.med,
                                          cohort = cohort,
                                          query_type = "med")

  cohort[,"drug"] <-   combine_query_boolean(db_query = db.qry.drug,
                                             cohort = cohort,
                                             query_type = "drug",
                                             time_prev = drug_time_prev,
                                             time_post = 0,
                                             numobs = drug_numobs)

  ### Create the varaible of interest from these
  ### if an individual has history of type 1 and type 2, they will be classed as type 1
  variable_dat <- dplyr::mutate(cohort, impotence = pmax(med, drug))

  ### Reduce to variables of interest
  variable_dat <- variable_dat[,c("patid", "impotence")]

  ### Change name of variable to varname
  colnames(variable_dat)[colnames(variable_dat) == "impotence"] <- varname

  ### Implement output
  implement_output(variable_dat, varname, out_save_disk, out_subdir, out_filepath, return_output)

}
