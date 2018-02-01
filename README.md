
<!-- README.md is generated from README.Rmd. Please edit that file -->
lutz
====

Look up timezones of point coordinates, as x, y pairs or from an `sf` object. It uses spatial data on timezones from: <https://github.com/evansiroky/timezone-boundary-builder>

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
tz_lookup(-123, 49.5)
#> [1] "America/Vancouver"

data(meuse, package = "sp")

# numeric x and y
tz_lookup(meuse$x, meuse$y, crs = 28992)
#>   [1] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>   [4] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>   [7] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [10] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [13] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [16] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [19] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [22] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [25] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [28] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [31] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [34] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [37] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [40] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [43] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [46] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [49] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [52] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [55] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [58] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [61] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [64] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [67] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [70] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [73] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [76] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [79] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [82] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
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
#> [121] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [124] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [127] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [130] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [133] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [136] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [139] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [142] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [145] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [148] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [151] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [154] "Europe/Amsterdam" "Europe/Amsterdam"

# With a sf object:
meuse_sf = sf::st_as_sf(meuse, coords = c("x", "y"), crs = 28992, agr = "constant")

tz_lookup(meuse_sf)
#>   [1] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>   [4] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>   [7] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [10] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [13] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [16] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [19] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [22] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [25] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [28] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [31] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [34] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [37] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [40] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [43] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [46] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [49] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [52] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [55] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [58] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [61] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [64] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [67] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [70] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [73] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [76] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [79] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#>  [82] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
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
#> [121] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [124] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [127] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [130] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [133] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [136] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [139] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [142] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [145] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [148] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [151] "Europe/Amsterdam" "Europe/Amsterdam" "Europe/Amsterdam"
#> [154] "Europe/Amsterdam" "Europe/Amsterdam"
```
