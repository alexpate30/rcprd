###
### rEHR functions
###
test_that("check connect_database", {

  ### Open connection
  aurum_extract <- connect_database(file.path(tempdir(), "temp.sqlite"))

  ### Check answer is same whether stabilisation used or not
  expect_true(inherits(aurum_extract, "DBIConnection"))

  ## clean up
  RSQLite::dbDisconnect(aurum_extract)
  unlink(file.path(tempdir(), "temp.sqlite"))

})

