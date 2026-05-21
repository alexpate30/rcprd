# Create the appropriate directory system to be able to run functions without specifying hard filepaths

Create the appropriate directory system to be able to run functions
without specifying hard filepaths

## Usage

``` r
create_directory_system(rootdir = NULL)
```

## Arguments

- rootdir:

  Directory within which to create the directory system

## Value

No return value, creates directory system in the specified directory.

## Examples

``` r
## Create directory system compatible with rcprd's automatic saving of output
create_directory_system(tempdir())
#> Directory system being created in /tmp/Rtmp0A4veK
file.exists(file.path(tempdir(),"data"))
#> [1] TRUE
file.exists(file.path(tempdir(),"code"))
#> [1] TRUE
file.exists(file.path(tempdir(),"codelists"))
#> [1] TRUE

## Return filespace to how it was prior to example
delete_directory_system(tempdir())
#> Directory system being deleted from /tmp/Rtmp0A4veK
```
