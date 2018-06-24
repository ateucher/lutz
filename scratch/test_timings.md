
These are tests to figure out how to include a full timezone map in lutz
that is small enough to submit to CRAN (\<5MB), but still provides a
very high degree of accuracy. Simplify the full timezone map at various
levels and compare accuracy vs size. Performance is a secondary
consideration.

``` r
library(lutz)
library(sf)
```

    ## Linking to GEOS 3.6.2, GDAL 2.3.0, proj.4 5.1.0

``` r
library(rmapshaper)
library(purrr)

## Get the full timezone geojson from https://github.com/evansiroky/timezone-boundary-builder
download.file("https://github.com/evansiroky/timezone-boundary-builder/releases/download/2018d/timezones-with-oceans.geojson.zip",
              destfile = "tz.zip")
unzip("tz.zip", exdir = ".")
tz_full <- read_sf("dist/combined-with-oceans.json")
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
|     0.001 |   1140672 |           112396 | 13.665 |  494693 |       4305 | 0.9913727 |        0 |      1002 |
|     0.010 |   1892720 |           387088 | 15.082 |  498569 |        429 | 0.9991403 |        0 |      1002 |
|     0.050 |   5486944 |          1456332 | 24.563 |  498951 |         47 | 0.9999058 |        0 |      1002 |
|     0.100 |   9989040 |          2788204 | 33.730 |  498982 |         16 | 0.9999679 |        0 |      1002 |
|     0.150 |  14492336 |          4117892 | 42.901 |  498992 |          6 | 0.9999880 |        0 |      1002 |
|     0.200 |  18996096 |          5418132 | 52.160 |  498993 |          5 | 0.9999900 |        0 |      1002 |
