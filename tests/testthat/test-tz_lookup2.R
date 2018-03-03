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
