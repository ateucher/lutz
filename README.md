
<!-- README.md is generated from README.Rmd. Please edit that file -->
lutz
====

Input latitude and longitude values or an `sf` or `sfc` POINT object and get back the timezone in which they exist. This package uses the V8 package to access the [`tz-lookup.js` javascript library](https://github.com/darkskyapp/tz-lookup/).

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
data(meuse, package = "sp")
meuse_sf = sf::st_as_sf(meuse, coords = c("x", "y"), crs = 28992, agr = "constant")

tz_lookup_sf(meuse_sf)
#>   [1] "Europe/Brussels"  "Europe/Amsterdam" "Europe/Amsterdam"
#>   [4] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>   [7] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [10] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [13] "Europe/Brussels"  "Europe/Amsterdam" "Europe/Amsterdam"
#>  [16] "Europe/Brussels"  "Europe/Brussels"  "Europe/Brussels" 
#>  [19] "Europe/Brussels"  "Europe/Amsterdam" "Europe/Amsterdam"
#>  [22] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [25] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [28] "Europe/Amsterdam" "Europe/Brussels"  "Europe/Amsterdam"
#>  [31] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [34] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [37] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [40] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [43] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [46] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [49] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [52] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [55] "Europe/Brussels"  "Europe/Brussels"  "Europe/Brussels" 
#>  [58] "Europe/Brussels"  "Europe/Amsterdam" "Europe/Brussels" 
#>  [61] "Europe/Brussels"  "Europe/Amsterdam" "Europe/Amsterdam"
#>  [64] "Europe/Brussels"  "Europe/Brussels"  "Europe/Brussels" 
#>  [67] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [70] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [73] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [76] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [79] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [82] "Europe/Amsterdam" "Europe/Brussels"  "Europe/Amsterdam"
#>  [85] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [88] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [91] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [94] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [97] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [100] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [103] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [106] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [109] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [112] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [115] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [118] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [121] "Europe/Amsterdam" "Europe/Brussels"  "Europe/Brussels" 
#> [124] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [127] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Brussels" 
#> [130] "Europe/Brussels"  "Europe/Amsterdam" "Europe/Amsterdam"
#> [133] "Europe/Brussels"  "Europe/Amsterdam" "Europe/Amsterdam"
#> [136] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [139] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [142] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [145] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [148] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [151] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [154] "Europe/Amsterdam" "Europe/Brussels"
```
