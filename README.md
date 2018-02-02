
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/ateucher/lutz.svg?branch=master)](https://travis-ci.org/ateucher/lutz)

lutz (look up timezones)
========================

Input latitude and longitude values or an `sf` or `sfc` POINT object and get back the timezone in which they exist. This package uses the **V8** package to access the [`tz-lookup.js` javascript library](https://github.com/darkskyapp/tz-lookup/).

Installation
------------

You can install lutz from github with:

``` r
# install.packages("devtools")
devtools::install_github("ateucher/lutz")
```

Example
-------

``` r
library(lutz)
tz_lookup(49.5, -123.5)
#> [1] "America/Vancouver"

tz_lookup(lat = c(48.9, 38.5, 63.1, -25), lon = c(-123.5, -110.2, -95.0, 130))
#> [1] "America/Vancouver"    "America/Denver"       "America/Rankin_Inlet"
#> [4] "Australia/Darwin"

# With a sf object:
library(sf)
#> Linking to GEOS 3.6.2, GDAL 2.2.3, proj.4 4.9.3
library(ggplot2) # this requires the devlopment version of ggplot2

# Create an sf object out of the included state.center dataset:
pts <- lapply(seq_along(state.center$x), function(i) {
  st_point(c(state.center$x[i], state.center$y[i]))
})
state_centers_sf <- st_sf(st_sfc(pts))

# Use tz_lookup_sf to find the timezones
state_centers_sf$tz <- tz_lookup_sf(state_centers_sf)

ggplot() + 
  geom_sf(data = state_centers_sf, aes(colour = tz)) + 
  theme_minimal() + 
  coord_sf(datum = NA)
```

![](README-example-1.png)
