tz_url <- "https://github.com/evansiroky/timezone-boundary-builder/releases/download/2017c/timezones.geojson.zip"
tmp <- tempfile()
download.file(tz_url, destfile = tmp)
unzip(tmp, exdir = "data-raw")
files <- list.files("data-raw", recursive = TRUE, full.names = TRUE)

tz <- sf::read_sf(files[grepl(".json$", files)])

sf::st_crs(tz)

devtools::use_data(tz, overwrite = TRUE, compress = "xz")
