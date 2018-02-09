test\_timings.R
================
ateucher
Thu Feb 8 16:08:40 2018

``` r
library(lutz)
library(sf)
```

    ## Linking to GEOS 3.6.2, GDAL 2.2.3, proj.4 4.9.3

``` r
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
```

    ## although coordinates are longitude/latitude, st_intersects assumes that they are planar

    ## although coordinates are longitude/latitude, st_intersects assumes that they are planar
    ## although coordinates are longitude/latitude, st_intersects assumes that they are planar
    ## although coordinates are longitude/latitude, st_intersects assumes that they are planar
    ## although coordinates are longitude/latitude, st_intersects assumes that they are planar

    ## Warning in bind_rows_(x, .id): Vectorizing 'object_size' elements may not
    ## preserve their attributes

    ## Warning in bind_rows_(x, .id): Vectorizing 'object_size' elements may not
    ## preserve their attributes

    ## Warning in bind_rows_(x, .id): Vectorizing 'object_size' elements may not
    ## preserve their attributes

    ## Warning in bind_rows_(x, .id): Vectorizing 'object_size' elements may not
    ## preserve their attributes

``` r
tests
```

    ## # A tibble: 4 x 8
    ##      keep    size  time matches mismatches accuracy ref_nas simp_nas
    ##     <dbl>   <dbl> <dbl>   <int>      <int>    <dbl>   <int>    <int>
    ## 1 0.00100  873288  2.88   26989        393    0.986   72219    72474
    ## 2 0.0100  1449888  3.04   27684         52    0.998   72219    72261
    ## 3 0.0500  4399888  3.92   27770          8    1.000   72219    72222
    ## 4 0.100   8300080  5.21   27779          1    1.000   72219    72220

``` r
readr::write_csv(tests, "tests.csv")
```
