# Open connection to SQLite database

Open connection to SQLite database

## Usage

``` r
connect_database(dbname)
```

## Arguments

- dbname:

  Name of SQLite database on hard disk (including full file path
  relative to working directory)

## Value

No return value, called to open a database connection.

## Examples

``` r

## Connect to a database
aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

## Check connection is open
inherits(aurum_extract, "DBIConnection")
#> [1] TRUE

## clean up
RSQLite::dbDisconnect(aurum_extract)
unlink(file.path(tempdir(), "temp.sqlite"))
```
