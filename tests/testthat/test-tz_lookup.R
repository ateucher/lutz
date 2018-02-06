context("tz_lookup works")

test_that("make_ctx creates a working context", {
  ct <- make_ctx()
  expect_is(ct, c("V8", "environment"))
  expect_equal(ct$eval("1 + 1"), "2")
  expect_equal(ct$eval("tzlookup(1,1);"), "Etc/GMT")
})

test_that("tz_lookup_coords works", {
  expect_equal(tz_lookup_coords(1,1), "Etc/GMT")
  expect_equal(tz_lookup_coords(c(70, -70), c(30, -30)), c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup_coords(1, 1:2), "lat and lon must numeric vectors be of the same length")
  expect_error(tz_lookup_coords("a", "b"), "lat and lon must numeric vectors be of the same length")
  expect_error(tz_lookup_coords(100, 500), "invalid coordinates")
})

test_that("tz_lookup_coords deals with NAs", {
  expect_equal(tz_lookup_coords(NA_real_, NA_real_), NA_character_)
  expect_equal(tz_lookup_coords(1, NA_real_), NA_character_)
  expect_equal(tz_lookup_coords(rep(NA_real_, 2), rep(NA_real_, 2)), rep(NA, 2))
  expect_equal(tz_lookup_coords(c(NA_real_, 1), c(NA_real_, 1)), c(NA, "Etc/GMT"))
  expect_equal(tz_lookup_coords(c(NA_real_, 1), c(1, 1)), c(NA, "Etc/GMT"))
})

test_that("tz_lookup.sf works", {
  skip_if_not_installed("sf")
  pt <- sf::st_sfc(sf::st_point(c(1,1)))
  pts <- sf::st_sfc(sf::st_point(c(30, 70)), sf::st_point(c(-30, -70)))
  expect_equal(tz_lookup(pt), "Etc/GMT")
  expect_equal(tz_lookup(pts), c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup(sf::st_sfc(sf::st_linestring(matrix(1:6,3)))),
               "This only works with points")
  expect_error(tz_lookup_coords(pts), "It looks like you are trying to get the tz of an sf/sfc or SpatialPoints object")
  expect_equal(tz_lookup(pt, 3005), "Etc/GMT+9")
  expect_equal(tz_lookup(pt, "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"),
               "Etc/GMT+9")
})

test_that("tz_lookup.SpatialPoints works", {
  skip_if_not_installed("sp")
  skip_if_not_installed("rgdal")
  pt <- sp::SpatialPoints(matrix(c(1,1), nrow = 1))
  pts <- sp::SpatialPoints(matrix(c(30, 70,-30, -70), nrow = 2, byrow = TRUE))
  expect_equal(tz_lookup(pt), "Etc/GMT")
  expect_equal(tz_lookup(pts), c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup_coords(pts), "It looks like you are trying to get the tz of an sf/sfc or SpatialPoints object")
  expect_equal(tz_lookup(pt, "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"),
               "Etc/GMT+9")
  expect_equal(tz_lookup(pt, 3005), "Etc/GMT+9")
})
