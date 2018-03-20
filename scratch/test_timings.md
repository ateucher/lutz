
These are tests to figure out how to include a full timezone map in lutz
that is small enough to submit to CRAN (\<5MB), but still provides a
very high degree of accuracy. Simplify the full timezone map at various
levels and compare accuracy vs size. Performance is a secondary
consideration.

``` r
library(lutz)
library(sf)
```

    ## Linking to GEOS 3.6.1, GDAL 2.1.3, proj.4 4.9.3

``` r
library(rmapshaper)
library(purrr)

## Get the full timezone geojson from https://github.com/evansiroky/timezone-boundary-builder
download.file("https://github.com/evansiroky/timezone-boundary-builder/releases/download/2017c/timezones.geojson.zip",
              destfile = "tz.zip")
unzip("tz.zip", exdir = ".")
tz_full <- read_sf("dist/combined.json")
```

A function that takes a vector of values to pass to the `keep` argument
in `rmapshaper::ms_simplify()`, an `sf` POINTS object, and the full
unmodified timezone map. It will simplify the map using each value of
`keep` and get timezone values from the simplified map, outputting size,
time, accuracy etc.

``` r
compare_tz_ver <- function(keep, ll, tz_full) {
  ref_ll_tz <- sf::st_join(ll, tz_full)
  map_df(keep, ~ {
    tz_simp <- rmapshaper::ms_simplify(tz_full, keep = .x, keep_shapes = TRUE,
                                            explode = TRUE, sys = TRUE)
    size <- object.size(tz_simp)
    tmp <- tempfile(fileext = ".rda")
    on.exit(unlink(tmp))
    save(tz_simp, file = tmp, compress = "xz")
    file_size <- file.info(tmp)$size
    timing <- system.time(test_ll_tz <- sf::st_join(ll_sf, tz_simp))
    comp <- ref_ll_tz$tzid == test_ll_tz$tzid
    matches <- sum(comp, na.rm = TRUE)
    mismatches <- sum(!comp, na.rm = TRUE)
    list(keep_arg = .x,
         obj_size = size,
         compressed_size = file_size,
         time = timing["elapsed"],
         matches = matches,
         mismatches = mismatches,
         accuracy = matches / (matches + mismatches),
         ref_nas = sum(is.na(ref_ll_tz$tzid)),
         simp_nas = sum(is.na(test_ll_tz$tzid)))
  })
}
```

Make an sf points object of n points randomly distributed around the
globe. The timezone file only has land, so points in the oceans don’t
get evaluated.

``` r
set.seed(42)
n <- 500000
ll <- data.frame(lat = runif(n, -90, 90), lon = runif(n, -180, 180))
ll_sf <- st_as_sf(ll, coords = c("lon", "lat"), crs = 4326)

tests <- compare_tz_ver(keep = c(0.001, 0.01, 0.05, 0.1, 0.15, 0.2),
                        ll = ll_sf, tz_full = tz_full)
```

We are looking for a high accuracy but where compressed file size is
under 5MB so can still submit to
CRAN

``` r
knitr::kable(tests)
```

| keep\_arg | obj\_size | compressed\_size |   time | matches | mismatches |  accuracy | ref\_nas | simp\_nas |
| --------: | --------: | ---------------: | -----: | ------: | ---------: | --------: | -------: | --------: |
|     0.001 |    873288 |            97052 | 16.371 |  135216 |       2099 | 0.9847140 |   360785 |    361984 |
|     0.010 |   1449888 |           322372 | 16.353 |  138805 |        224 | 0.9983888 |   360785 |    360936 |
|     0.050 |   4399888 |          1220264 | 20.715 |  139169 |         30 | 0.9997845 |   360785 |    360801 |
|     0.100 |   8300080 |          2372028 | 27.114 |  139200 |         12 | 0.9999138 |   360785 |    360788 |
|     0.150 |  12304208 |          3555076 | 34.005 |  139209 |          6 | 0.9999569 |   360785 |    360785 |
|     0.200 |  16372400 |          4735724 | 40.416 |  139210 |          5 | 0.9999641 |   360785 |    360785 |
