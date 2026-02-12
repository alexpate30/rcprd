# Deletes directory system created by `delete_directory_system`

Deletes directory system created by `delete_directory_system`. Primarily
used to restore filespaces to original in examples/tests/vignettes.

## Usage

``` r
delete_directory_system(rootdir = NULL)
```

## Arguments

- rootdir:

  Directory within which to delete the directory system

## Value

No return value, deletes directory system in the specified directory.

## Examples

``` r
## Print current working directory
getwd()
#> [1] "/home/runner/work/rcprd/rcprd/docs/reference"

## Create directory system
create_directory_system(tempdir())
#> Directory system being created in /tmp/RtmpKb7HPK
file.exists(file.path(tempdir(),"data"))
#> [1] TRUE
file.exists(file.path(tempdir(),"code"))
#> [1] TRUE
file.exists(file.path(tempdir(),"codelists"))
#> [1] TRUE

## Return filespace to how it was prior to example
delete_directory_system(tempdir())
#> Directory system being deleted from /tmp/RtmpKb7HPK
file.exists(file.path(tempdir(),"data"))
#> [1] FALSE
file.exists(file.path(tempdir(),"code"))
#> [1] FALSE
file.exists(file.path(tempdir(),"codelists"))
#> [1] FALSE
```
