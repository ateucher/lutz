context("test-tzlookup2.R")

test_that("tz_lookup_coords2 works", {
  expect_equal(tz_lookup_coords2(70,30), "Europe/Oslo")
  # Check that NAs are filled in
  expect_equal(tz_lookup_coords2(c(70, -70), c(30, -30)), c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup_coords2(1, 1:2), "lat and lon must numeric vectors be of the same length")
  expect_error(tz_lookup_coords2("a", "b"), "lat and lon must numeric vectors be of the same length")
  expect_error(tz_lookup_coords2(100, 500), "invalid coordinates")
})

test_that("tz_lookup_coords2 deals with NAs", {
  expect_equal(tz_lookup_coords2(NA_real_, NA_real_), NA_character_)
  expect_equal(tz_lookup_coords2(1, NA_real_), NA_character_)
  expect_equal(tz_lookup_coords2(rep(NA_real_, 2), rep(NA_real_, 2)), rep(NA_character_, 2))
  expect_equal(tz_lookup_coords2(c(NA_real_, 70), c(NA_real_, 30)), c(NA, "Europe/Oslo"))
  expect_equal(tz_lookup_coords2(c(NA_real_, 70), c(1, 30)), c(NA, "Europe/Oslo"))
})

test_that("tz_lookup2.sf works", {
  skip_if_not_installed("sf")
  pt <- sf::st_sfc(sf::st_point(c(1,1)))
  pts <- sf::st_sfc(sf::st_point(c(30, 70)), sf::st_point(c(-30, -70)))
  expect_equal(tz_lookup2(pt), "Etc/GMT")
  expect_equal(tz_lookup2(pts), c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup2(sf::st_sfc(sf::st_linestring(matrix(1:6,3)))),
               "This only works with points")
  expect_error(tz_lookup_coords2(pts), "It looks like you are trying to get the tz of an sf/sfc or SpatialPoints object")
  expect_equal(tz_lookup2(pt, 3005), "Etc/GMT+9")
  expect_equal(tz_lookup2(pt, "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"),
               "Etc/GMT+9")
})

test_that("tz_lookup2.SpatialPoints works", {
  skip_if_not_installed("sp")
  skip_if_not_installed("rgdal")
  pt <- sp::SpatialPoints(matrix(c(1,1), nrow = 1))
  pts <- sp::SpatialPoints(matrix(c(30, 70,-30, -70), nrow = 2, byrow = TRUE))
  expect_equal(tz_lookup2(pt), "Etc/GMT")
  expect_equal(tz_lookup2(pts), c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup_coords2(pts), "It looks like you are trying to get the tz of an sf/sfc or SpatialPoints object")
  expect_equal(tz_lookup2(pt, "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"),
               "Etc/GMT+9")
  expect_equal(tz_lookup2(pt, 3005), "Etc/GMT+9")
})
