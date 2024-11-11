#' Create the appropriate directory system to be able to run functions without specifying hard filepaths
#'
#' @description
#' Create the appropriate directory system to be able to run functions without specifying hard filepaths
#'
#' @param rootdir Directory within which to create the directory system
#'
#' @returns No return value, creates directory system in the working directory.
#'
#' @examples
#'
#' \dontrun{
#' ## Print current working directory
#' getwd()
#'
#' ## Create directory system compatible with rcprd's automatic saving of
#' ## output
#' create_directory_system()
#'
#' ## Connect
#' aurum_extract <- connect_database("data/sql/temp.sqlite")
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
#' ## Extract a history of type variable and save to disc automatically,
#' ## by just specifying name of database
#' extract_ho(pat,
#' codelist_vector = "187341000000114",
#' indexdt = "fup_start",
#' db = "temp",
#' tab = "observation",
#' out_save_disk = TRUE)
#'
#' ## Read file from disk into R workspace
#' readRDS("data/extraction/var_ho.rds")
#' }
#'
#'
#' @export
create_directory_system <- function(rootdir = NULL){

  ### Start by setting and stating the root directory everything will be created in
  if (is.null(rootdir)){
    rootdir <- getwd()
  }
  message(paste("Directory system being created in", rootdir))

  ### Create the three key sub-directories
  ## code
  if (!file.exists(paste(rootdir, "/code", sep = ""))){
    dir.create(paste(rootdir, "/code", sep = ""))
  }

  ## data
  if (!file.exists(paste(rootdir, "/data", sep = ""))){
    dir.create(paste(rootdir, "/data", sep = ""))
    ## Create neccesary sub-directories in data
    dir.create(paste(rootdir, "/data/unzip", sep = ""))
    dir.create(paste(rootdir, "/data/extraction", sep = ""))
    dir.create(paste(rootdir, "/data/sql", sep = ""))
  }

  ## codelists
  if (!file.exists(paste(rootdir, "/codelists", sep = ""))){
    dir.create(paste(rootdir, "/codelists", sep = ""))
    ## Create neccesary sub-directories in codelists
    dir.create(paste(rootdir, "/codelists/analysis", sep = ""))
  }

}
