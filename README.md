
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Travis-CI Build
Status](https://travis-ci.org/ateucher/lutz.svg?branch=master)](https://travis-ci.org/ateucher/lutz)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/ateucher/lutz?branch=master&svg=true)](https://ci.appveyor.com/project/ateucher/lutz)
[![Coverage
Status](https://img.shields.io/codecov/c/github/ateucher/lutz/master.svg)](https://codecov.io/github/ateucher/lutz?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/lutz)](https://cran.r-project.org/package=lutz)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/lutz)](https://cran.r-project.org/package=lutz)
<!-- badges: end -->

# lutz (look up time zones)

## Lookup the time zone of coordinates

Input latitude and longitude values or an `sf/sfc` POINT object and get
back the time zone in which they exist. Two methods are implemented. One
is very fast and uses Rcpp in conjunction with source data from
(<https://github.com/darkskyapp/tz-lookup/>). However, speed comes at
the cost of accuracy - near time zone borders away from populated
centres there is a chance that it will return the incorrect time zone.

The other method is slower but more accurate - it uses the sf package to
intersect points with a detailed map of time zones from
[here](https://github.com/evansiroky/timezone-boundary-builder).

## time zone utility functions

**lutz** also contains several utility functions for helping to
understand and visualize time zones, such as listing of world time
zones,including information about daylight savings times and their
offsets from UTC. You can also plot a time zone to visualize the UTC
offset over a year and when daylight savings times are in effect.

## Installation

You can install lutz from CRAN with:

``` r
install.packages("lutz")
```

Or you can install the development version from github with:

``` r
# install.packages("devtools")
devtools::install_github("ateucher/lutz")
```

## Examples

There are two functions in this package for looking up the time zones of
coordinates: `tz_lookup()` which works with both `sf/sfc` and
`SpatialPoints` objects, and `tz_lookup_coords` for looking up lat/long
pairs. Use the `method` argument to choose the `"fast"` or `"accurate"`
method.

### With coordinates. They must be lat/long in decimal degrees:

``` r
library(lutz)
tz_lookup_coords(49.5, -123.5, method = "fast")
#> [1] "America/Vancouver"
tz_lookup_coords(49.5, -123.5, method = "accurate")
#> [1] "America/Vancouver"

tz_lookup_coords(lat = c(48.9, 38.5, 63.1, -25), lon = c(-123.5, -110.2, -95.0, 130))
#> [1] "America/Vancouver"    "America/Denver"       "America/Rankin_Inlet"
#> [4] "Australia/Darwin"
```

### With `sf` objects:

``` r
library(sf)
library(ggplot2) # this requires the devlopment version of ggplot2

# Create an sf object out of the included state.center dataset:
pts <- lapply(seq_along(state.center$x), function(i) {
  st_point(c(state.center$x[i], state.center$y[i]))
})
state_centers_sf <- st_sf(st_sfc(pts))

# Use tz_lookup_sf to find the time zones
state_centers_sf$tz <- tz_lookup(state_centers_sf)
state_centers_sf$tz <- tz_lookup(state_centers_sf, method = "accurate")

ggplot() + 
  geom_sf(data = state_centers_sf, aes(colour = tz)) + 
  theme_minimal() + 
  coord_sf(datum = NA)
```

![](man/figures/unnamed-chunk-4-1.png)<!-- -->

### With `SpatialPoints` objects:

``` r
library(sp)
state_centers_sp <- as(state_centers_sf, "Spatial")

state_centers_sp$tz <- tz_lookup(state_centers_sp)

ggplot(cbind(as.data.frame(coordinates(state_centers_sp)), tz = state_centers_sp$tz), 
       aes(x = coords.x1, y = coords.x2, colour = tz)) + 
  geom_point() + 
  coord_fixed() + 
  theme_minimal()
```

![](man/figures/unnamed-chunk-5-1.png)<!-- -->

Note that there are some regions in the world where a single point can
land in two different overlapping time zones. The `"accurate"` method
[includes
these](https://github.com/evansiroky/timezone-boundary-builder/releases/tag/2018g),
however the method used in the `"fast"` does not include overlapping
time zones ([at least for
now](https://github.com/darkskyapp/tz-lookup/issues/34)).

We can compare the accuracy of both methods to the high-resolution time
zone map provided by
<https://github.com/evansiroky/timezone-boundary-builder>. This is the
map that is used by `lutz` for the `"accurate"` method, but in `lutz` it
is simplified by about 80% to be small enough to fit in the package.

``` r
## Get the full time zone geojson from https://github.com/evansiroky/timezone-boundary-builder
download.file("https://github.com/evansiroky/timezone-boundary-builder/releases/download/2019a/timezones-with-oceans.geojson.zip",
                destfile = "tz.zip")
unzip("tz.zip", exdir = "data-raw/dist/")
```

``` r
library(lutz)
library(sf)
library(purrr)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

tz_full <- read_sf("data-raw/dist/combined-with-oceans.json")
# Create a data frame of 500000 lat/long pairs:
set.seed(1)
n <- 500000
ll <- data.frame(id = seq(n), lat = runif(n, -90, 90), lon = runif(n, -180, 180))
ll_sf <- st_as_sf(ll, coords = c("lon", "lat"), crs = 4326)

# Overlay those points with the full high-resolution time zone map:
ref_ll_tz <- sf::st_join(ll_sf, tz_full)
#> although coordinates are longitude/latitude, st_intersects assumes that they are planar
#> although coordinates are longitude/latitude, st_intersects assumes that they are planar

# Combine those that had overlapping time zones
ref_ll_tz <- ref_ll_tz %>% 
  st_set_geometry(NULL) %>% 
  group_by(id) %>% 
  summarize(tzid = paste(tzid, collapse = "; "))

# run tz_lookup with both `"fast"` and `"accurate"` methods and compare with 
# the time zones looked up with the high-resolution map:
tests <- map_df(c("fast", "accurate"), ~ {
  time <- system.time(test_ll_tz <- tz_lookup(ll_sf, method = .x, warn = FALSE))
  comp <- ref_ll_tz$tzid == test_ll_tz
  matches <- sum(comp, na.rm = TRUE)
  mismatches <- sum(!comp, na.rm = TRUE)
  list(
    method = .x,
    time = time["elapsed"],
    matches = matches,
    mismatches = mismatches,
    accuracy = matches / (matches + mismatches),
    ref_nas = sum(is.na(ref_ll_tz$tzid)),
    fun_nas = sum(is.na(test_ll_tz))
    )
})
#> Warning in tz_lookup_accurate.sf(x, crs): Some points are in areas with
#> more than one timezone defined.These are often disputed areas and should be
#> treated with care.
```

``` r
knitr::kable(tests)
```

| method   |   time | matches | mismatches | accuracy | ref\_nas | fun\_nas |
| :------- | -----: | ------: | ---------: | -------: | -------: | -------: |
| fast     |  1.132 |  371946 |     128054 | 0.743892 |        0 |        0 |
| accurate | 26.363 |  499949 |         51 | 0.999898 |        0 |        0 |

## time zone utility functions

### `tz_plot()`

``` r
tz_plot("America/Vancouver")
```

![](man/figures/unnamed-chunk-9-1.png)<!-- -->

### `tz_offset()`

``` r
# A Date object
tz_offset(Sys.Date(), "Africa/Algiers")
#>          tz_name  date_time zone is_dst utc_offset_h
#> 1 Africa/Algiers 2019-07-13  CET  FALSE            1


# A Date-like character string
tz_offset("2017-03-01", tz = "Singapore")
#>     tz_name  date_time zone is_dst utc_offset_h
#> 1 Singapore 2017-03-01  +08  FALSE            8


# A POSIXct date-time object
tz_offset(Sys.time())
#> Warning: You supplied an object of class POSIXct that does not have a
#> timezone attribute, and did not specify one inthe 'tz' argument. Defaulting
#> to current (America/Vancouver).
#>             tz_name           date_time zone is_dst utc_offset_h
#> 1 America/Vancouver 2019-07-13 15:49:18  PDT   TRUE           -7
```

### `tz_list()`

``` r
tz_list() %>% 
  head(20) %>% 
  knitr::kable()
```

| tz\_name            | zone | is\_dst | utc\_offset\_h |
| :------------------ | :--- | :------ | -------------: |
| Africa/Abidjan      | GMT  | FALSE   |              0 |
| Africa/Accra        | GMT  | FALSE   |              0 |
| Africa/Addis\_Ababa | EAT  | FALSE   |              3 |
| Africa/Algiers      | CET  | FALSE   |              1 |
| Africa/Asmara       | EAT  | FALSE   |              3 |
| Africa/Asmera       | EAT  | FALSE   |              3 |
| Africa/Bamako       | GMT  | FALSE   |              0 |
| Africa/Bangui       | WAT  | FALSE   |              1 |
| Africa/Banjul       | GMT  | FALSE   |              0 |
| Africa/Bissau       | GMT  | FALSE   |              0 |
| Africa/Blantyre     | CAT  | FALSE   |              2 |
| Africa/Brazzaville  | WAT  | FALSE   |              1 |
| Africa/Bujumbura    | CAT  | FALSE   |              2 |
| Africa/Cairo        | EET  | FALSE   |              2 |
| Africa/Casablanca   | \+01 | FALSE   |              1 |
| Africa/Casablanca   | \+00 | TRUE    |              0 |
| Africa/Ceuta        | CET  | FALSE   |              1 |
| Africa/Ceuta        | CEST | TRUE    |              2 |
| Africa/Conakry      | GMT  | FALSE   |              0 |
| Africa/Dakar        | GMT  | FALSE   |              0 |
