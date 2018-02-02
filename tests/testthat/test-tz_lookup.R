context("tz_lookup works")

test_that("make_ctx creates a working context", {
  ct <- make_ctx()
  expect_is(ct, c("V8", "environment"))
  expect_equal(ct$eval("1 + 1"), "2")
  expect_equal(ct$eval("tzlookup(1,1);"), "Etc/GMT")
})

test_that("tz_lookup works", {
  expect_equal(tz_lookup(1,1), "Etc/GMT")
  expect_equal(tz_lookup(c(70, -70), c(30, -30)), c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup(1, 1:2), "lat and lon must numeric vectors be of the same length")
  expect_error(tz_lookup("a", "b"), "lat and lon must numeric vectors be of the same length")
  expect_error(tz_lookup(100, 500), "invalid coordinates")
})

test_that("tz_lookup_sf works", {
  skip_if_not_installed("sf")
  pt <- sf::st_sfc(sf::st_point(c(1,1)))
  pts <- sf::st_sfc(sf::st_point(c(30, 70)), sf::st_point(c(-30, -70)))
  expect_equal(tz_lookup_sf(pt), "Etc/GMT")
  expect_equal(tz_lookup_sf(pts), c("Europe/Oslo", "Etc/GMT+2"))
  expect_error(tz_lookup_sf(sf::st_sfc(sf::st_linestring(matrix(1:6,3)))),
               "This only works with points")
  expect_error(tz_lookup(pts), "It looks like you are trying to get the tz of an sf/sfc object")
  expect_equal(tz_lookup_sf(pt, 3005), "Etc/GMT+9")
})
