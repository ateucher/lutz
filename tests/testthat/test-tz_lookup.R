context("tz_lookup works")

test_that("warn works with tz_lookup", {
  expect_warning(tz_lookup_coords(70,30),
                 "Using 'fast' method")
  expect_warning(tz_lookup(sf::st_sfc(sf::st_point(c(1,1)))),
                 "Using 'fast' method")
})

test_that("errors when method is not one of fast, accurate", {
  expect_error(tz_lookup_coords(70,30, method = "great"),
               "method must be one of 'fast' or 'accurate'")
  expect_error(tz_lookup(sf::st_sfc(sf::st_point(c(1,1))), method = "great"),
               "method must be one of 'fast' or 'accurate'")
})

test_that("tz_lookup_coords works", {
  expect_equal(tz_lookup_coords(70,30, warn = FALSE), "Europe/Oslo")
  expect_equal(tz_lookup_coords(c(70, -70), c(30, -30), warn = FALSE),
               c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup_coords(1, 1:2, warn = FALSE),
               "lat and lon must be numeric vectors of the same length")
  expect_error(tz_lookup_coords("a", "b", warn = FALSE),
               "lat and lon must be numeric vectors of the same length")
  expect_error(tz_lookup_coords(100, 500, warn = FALSE), "invalid coordinates")
  expect_error(tz_lookup_coords(-100, -500, warn = FALSE), "invalid coordinates")
})

test_that("tz_lookup_coords deals with NAs", {
  expect_equal(tz_lookup_coords(NA_real_, NA_real_, warn = FALSE), NA_character_)
  expect_equal(tz_lookup_coords(1, NA_real_, warn = FALSE), NA_character_)
  expect_equal(tz_lookup_coords(rep(NA_real_, 2), rep(NA_real_, 2), warn = FALSE),
               rep(NA_character_, 2))
  expect_equal(tz_lookup_coords(c(NA_real_, 1), c(NA_real_, 1), warn = FALSE),
               c(NA_character_, "Etc/GMT"))
  expect_equal(tz_lookup_coords(c(NA_real_, 1), c(1, 1), warn = FALSE),
               c(NA_character_, "Etc/GMT"))
})

test_that("tz_lookup.sf works", {
  skip_if_not_installed("sf")
  pt <- sf::st_sfc(sf::st_point(c(1,1)))
  pts <- sf::st_sfc(sf::st_point(c(30, 70)), sf::st_point(c(-30, -70)))
  expect_equal(tz_lookup(pt, warn = FALSE), "Etc/GMT")
  expect_equal(tz_lookup(pts, warn = FALSE), c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup(sf::st_sfc(sf::st_linestring(matrix(1:6,3)))),
               "This only works with points")
  expect_error(tz_lookup_coords(pts, warn = FALSE),
               "It looks like you are trying to get the tz of an sf/sfc or SpatialPoints object") # nolint
  expect_equal(tz_lookup(pt, 3005, warn = FALSE), "Etc/GMT+9")
  expect_equal(tz_lookup(pt, "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs",
                         warn = FALSE), # nolint
               "Etc/GMT+9")
})

test_that("tz_lookup.SpatialPoints works", {
  skip_if_not_installed("sp")
  pt <- sp::SpatialPoints(matrix(c(1,1), nrow = 1))
  pts <- sp::SpatialPoints(matrix(c(30, 70,-30, -70), nrow = 2, byrow = TRUE))
  expect_equal(tz_lookup(pt, warn = FALSE), "Etc/GMT")
  expect_equal(tz_lookup(pts, warn = FALSE), c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup_coords(pts, warn = FALSE),
    "It looks like you are trying to get the tz of an sf/sfc or SpatialPoints object") # nolint
  # suppressing Warnings as PROJ can sometimes emit a warning
  expect_equal(suppressWarnings(tz_lookup(pt, "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs",
    warn = FALSE)), # nolint
  "Etc/GMT+9")
  expect_equal(suppressWarnings(tz_lookup(pt, 3005, warn = FALSE)),
               "Etc/GMT+9")
})
