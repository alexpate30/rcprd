#' Create the appropriate directory system to be able to run functions without specifying hard filepaths
#'
#' @description
#' Create the appropriate directory system to be able to run functions without specifying hard filepaths
#'
#' @param rootdir Directory within which to create the directory system
#'
#' @returns No return value, creates directory system in the specified directory.
#'
#' @examples
#' ## Create directory system compatible with rcprd's automatic saving of output
#' create_directory_system(tempdir())
#' file.exists(file.path(tempdir(),"data"))
#' file.exists(file.path(tempdir(),"code"))
#' file.exists(file.path(tempdir(),"codelists"))
#'
#' ## Return filespace to how it was prior to example
#' delete_directory_system(tempdir())
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

#' Deletes directory system created by \code{delete_directory_system}
#'
#' @description
#' Deletes directory system created by \code{delete_directory_system}. Primarily used to restore
#' filespaces to original in examples/tests/vignettes.
#'
#' @param rootdir Directory within which to delete the directory system
#'
#' @returns No return value, deletes directory system in the specified directory.
#'
#' @examples
#'
#' ## Print current working directory
#' getwd()
#'
#' ## Create directory system
#' create_directory_system(tempdir())
#' file.exists(file.path(tempdir(),"data"))
#' file.exists(file.path(tempdir(),"code"))
#' file.exists(file.path(tempdir(),"codelists"))
#'
#' ## Return filespace to how it was prior to example
#' delete_directory_system(tempdir())
#' file.exists(file.path(tempdir(),"data"))
#' file.exists(file.path(tempdir(),"code"))
#' file.exists(file.path(tempdir(),"codelists"))
#'
#' @export
delete_directory_system <- function(rootdir = NULL){

  ### Start by setting and stating the root directory everything will be created in
  if (is.null(rootdir)){
    rootdir <- getwd()
  }
  message(paste("Directory system being deleted from", rootdir))

  ### Create the three key sub-directories
  ## code
  if (file.exists(paste(rootdir, "/code", sep = ""))){
    unlink(paste(rootdir, "/code", sep = ""), recursive = TRUE)
  }

  ## data
  if (file.exists(paste(rootdir, "/data", sep = ""))){
    unlink(paste(rootdir, "/data", sep = ""), recursive = TRUE)
  }

  ## codelists
  if (file.exists(paste(rootdir, "/codelists", sep = ""))){
    unlink(paste(rootdir, "/codelists", sep = ""), recursive = TRUE)
  }

}
