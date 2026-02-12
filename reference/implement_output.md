# Internal function to implement saving extracted variable to disk or returning into R workspace.

Will save extracted variable to disk if `out_save_disk = TRUE`. Note it
relies on correct underlying structure of directories. Will output
extracted variable into R workspace if `return_output = TRUE`.

## Usage

``` r
implement_output(
  variable_dat,
  varname,
  out_save_disk,
  out_subdir,
  out_filepath,
  return_output
)
```

## Arguments

- variable_dat:

  Dataset containing variable

- varname:

  Name of variable to use in filename

- out_save_disk:

  If TRUE will save output to disk

- out_subdir:

  Sub-directory of data/ to save output into

- out_filepath:

  Full fiilepath to save dat onto

- return_output:

  If TRUE returns output into R workspace
