# Combine a database query with a cohort returning a 0/1 vector depending on whether each individual has a recorded code of interest.

An S3 generic function that can be used on database queries from Aurum
or GOLD extracts. Combine a database query with a cohort returning a 0/1
vector depending on whether each individual has a recorded code of
interest. `cohort` must contain variables `patid` and `indexdt`. The
database query will be merged with the cohort by variable `patid`. If an
individual has at least `numobs` observations between `time_prev` days
prior to `indexdt`, and `time_post` days after `indexdt`, a 1 will be
returned, 0 otherwise. The `type` of query must be specified for
appropriate data manipulation.

## Usage

``` r
combine_query_boolean(
  db_query,
  cohort,
  query_type = c("med", "drug"),
  time_prev = Inf,
  time_post = 0,
  numobs = 1
)
```

## Arguments

- db_query:

  Output from database query (ideally obtained through
  [`db_query`](https://alexpate30.github.io/rcprd/reference/db_query.md)).

- cohort:

  Cohort to combine with the database query.

- query_type:

  Type of query

- time_prev:

  Number of days prior to index date to look for codes.

- time_post:

  Number of days after index date to look for codes.

- numobs:

  Number of observations required to be observed in specified time
  window to return a 1.

## Value

A 0/1 vector.
