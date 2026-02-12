# Read in raw .txt patient file

Read in raw .txt patient file

## Usage

``` r
extract_txt_pat(filepath, ..., set = FALSE)
```

## Arguments

- filepath:

  File path to raw .txt file

- ...:

  Arguments to pass onto data.table::fread

- set:

  If `TRUE` will create a variable called `set` which will contain the
  number that comes after the word 'set' in the file name.
