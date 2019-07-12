context("time-zone utilities")

test_that("tz_list works", {
  expect_is(tz_list(), "data.frame")
})

test_that("plot_tz works", {
  expect_is(plot_tz("America/Vancouver"), "ggplot")
  expect_error(plot_tz("foo"), "foo is not a valid timezone")
})

test_that("tz_offset works", {
  expect_is(tz_offset(Sys.Date(), "America/Vancouver"), "data.frame")
  expect_is(tz_offset(Sys.time(), "America/Vancouver"), "data.frame")
  expect_is(tz_offset("2019-01-01", "America/Vancouver"), "data.frame")
  expect_is(tz_offset("2019-01-01 12:31:45", "America/Vancouver"), "data.frame")
  expect_is(tz_offset(as.POSIXlt(Sys.time(), tz = "America/Vancouver")),
            "data.frame")

  t <- Sys.time()
  attr(t, "tzone") <- NULL
  expect_warning(tz_offset(t), "You supplied an object of class")
  expect_warning(tz_offset(as.POSIXlt(Sys.time(), tz = "America/Vancouver"),
                           tz = "America/Moncton"),
                 "tz supplied is different")
})

test_that("tz_offset fails correctly", {
  expect_error(tz_offset("2019-01-01"),
               "If dt is a character or a Date, you must supply a timezone")
  expect_error(tz_offset(1),
               "dt must be of type POSIXct/lt, Date, or a character")
})
