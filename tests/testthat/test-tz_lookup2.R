context("test-tzlookup2.R")

test_that("tz_lookup_coords works with method = accurate", {
  expect_equal(tz_lookup_coords(70,30, method = "accurate"), "Europe/Oslo")
  expect_equal(tz_lookup_coords(c(70, -70), c(30, -30), method = "accurate"),
               c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup_coords(1, 1:2, method = "accurate"),
               "lat and lon must numeric vectors be of the same length")
  expect_error(tz_lookup_coords("a", "b", method = "accurate"),
               "lat and lon must numeric vectors be of the same length")
  expect_error(tz_lookup_coords(100, 500, method = "accurate"), "invalid coordinates")
  expect_error(tz_lookup_coords(-100, -500, method = "accurate"), "invalid coordinates")
})

test_that("tz_lookup_coords deals with NAs", {
  expect_equal(tz_lookup_coords(NA_real_, NA_real_, method = "accurate"), NA_character_)
  expect_equal(tz_lookup_coords(1, NA_real_, method = "accurate"), NA_character_)
  expect_equal(tz_lookup_coords(rep(NA_real_, 2), rep(NA_real_, 2), method = "accurate"),
               rep(NA_character_, 2))
  expect_equal(tz_lookup_coords(c(NA_real_, 70), c(NA_real_, 30), method = "accurate"),
               c(NA, "Europe/Oslo"))
  expect_equal(tz_lookup_coords(c(NA_real_, 70), c(1, 30), method = "accurate"),
               c(NA, "Europe/Oslo"))
})

test_that("tz_lookup.sf works", {
  skip_if_not_installed("sf")
  pt <- sf::st_sfc(sf::st_point(c(1,1)))
  pts <- sf::st_sfc(sf::st_point(c(30, 70)), sf::st_point(c(-30, -70)))
  expect_equal(tz_lookup(pt, method = "accurate"), "Etc/GMT")
  expect_equal(tz_lookup(pts, method = "accurate"), c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup(sf::st_sfc(sf::st_linestring(matrix(1:6,3)))),
               "This only works with points")
  expect_error(tz_lookup_coords(pts, method = "accurate"),
               "It looks like you are trying to get the tz of an sf/sfc or SpatialPoints object") # nolint
  expect_equal(tz_lookup(pt, 3005, method = "accurate"), "Etc/GMT+9")
  expect_equal(tz_lookup(pt, "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs", method = "accurate"), # nolint
               "Etc/GMT+9")
})

test_that("tz_lookup.SpatialPoints works", {
  skip_if_not_installed("sp")
  skip_if_not_installed("rgdal")
  pt <- sp::SpatialPoints(matrix(c(1,1), nrow = 1))
  pts <- sp::SpatialPoints(matrix(c(30, 70,-30, -70), nrow = 2, byrow = TRUE))
  expect_equal(tz_lookup(pt, method = "accurate"), "Etc/GMT")
  expect_equal(tz_lookup(pts, method = "accurate"), c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup_coords(pts, method = "accurate"),
               "It looks like you are trying to get the tz of an sf/sfc or SpatialPoints object") # nolint
  expect_equal(tz_lookup(pt, "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs", method = "accurate"), # nolint
               "Etc/GMT+9")
  expect_equal(tz_lookup(pt, 3005, method = "accurate"), "Etc/GMT+9")
})
