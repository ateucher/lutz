#' ---
#' output: github_document
#' ---

library(lutz)
library(sf)
library(rmapshaper)
library(purrr)
# download.file("https://github.com/evansiroky/timezone-boundary-builder/releases/download/2017c/timezones.geojson.zip",
#               destfile = "tz.zip")
# unzip("tz.zip", exdir = ".")
tz_full <- read_sf("../data-raw/dist/combined.json")

compare_tz_ver <- function(keep, ll, tz_full) {
  ref_ll_tz <- sf::st_join(ll, tz_full)
  map_df(keep, ~ {
    tz_simp <- rmapshaper::ms_simplify(tz_full, keep = .x, keep_shapes = TRUE,
                                            explode = TRUE, sys = TRUE)
    size <- object.size(tz_simp)
    timing <- system.time(test_ll_tz <- sf::st_join(ll_sf, tz_simp))
    comp <- ref_ll_tz$tzid == test_ll_tz$tzid
    matches <- sum(comp, na.rm = TRUE)
    mismatches <- sum(!comp, na.rm = TRUE)
    list(keep = .x,
         size = size,
         time = timing["elapsed"],
         matches = matches,
         mismatches = mismatches,
         accuracy = matches / (matches + mismatches),
         ref_nas = sum(is.na(ref_ll_tz$tzid)),
         simp_nas = sum(is.na(test_ll_tz$tzid)))
  })
  # output size, time, and accuracy
}

set.seed(1)
n <- 100000
ll <- data.frame(lat = runif(n, -90, 90), lon = runif(n, -180, 180))
ll_sf <- st_as_sf(ll, coords = c("lon", "lat"), crs = 4326)

tests <- compare_tz_ver(c(0.001, 0.01, 0.05, 0.1), ll_sf, tz_full = tz_full)

tests

readr::write_csv(tests, "tests.csv")

