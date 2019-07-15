is_wgs84 <- function(x) {
  # The most minimal specification of WGS84
  comp <- c("+proj=longlat", "+datum=WGS84", "+no_defs")
  x_str <- strsplit(sp::CRS(sp::proj4string(x))@projargs, " +")[[1]]
  all(comp %in% x_str)
}

wgs84_string <- function() {
  "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
}

fix_sp <- function(x, crs) {
  if (!requireNamespace("sp"))
    stop("You must have the sp package installed to use this function", # nocov
         call. = FALSE) # nocov

  if (is.numeric(crs)) crs <- paste0("+init=epsg:", crs)

  if (is.na(sp::proj4string(x))) {
    if (is.null(crs)) crs <- wgs84_string()
    sp::proj4string(x) <- sp::CRS(crs)
  }

  if (!is_wgs84(x)) {
    x <- sp::spTransform(x, sp::CRS(wgs84_string()))
  }
  x
}

fix_sf <- function(x, crs) {
  if (!requireNamespace("sf"))
    stop("You must have the sf package installed to use this function", # nocov
         call. = FALSE) # nocov

  if (!all(sf::st_geometry_type(x) == "POINT"))
    stop("This only works with points", call. = FALSE)

  if (is.na(sf::st_crs(x))) {
    if (is.null(crs)) crs <- 4326
    sf::st_crs(x) <- crs
  }

  transform <- sf::st_crs(x) != sf::st_crs(4326)
  if (transform) {
    x <- sf::st_transform(x, crs = 4326)
  }
  x
}

check_coords <- function(lat, lon) {
  if (!identical(length(lat), length(lon)) ||
      !all(is.numeric(lat) && is.numeric(lon))) {
    stop("lat and lon must numeric vectors be of the same length")
  }

  if (any(abs(stats::na.omit(lat)) > 90 |
          abs(stats::na.omit(lon)) > 180)) {
    stop("invalid coordinates", call. = FALSE)
  }
}

check_for_spatial <- function(x) {
  if (inherits(x, c("sf", "sfc", "SpatialPoints"))) {
    stop("It looks like you are trying to get the tz of an sf/sfc or SpatialPoints object! Use tz_lookup() instead.", # nolint
         call. = FALSE)
  }
}

warn_for_fast <- function() {
  warning("Using 'fast' method. This can cause inaccuracies in time zones
  near boundaries away from populated ares. Use the 'accurate'
  method if accuracy is more important than speed.", call. = FALSE)
}

tz_compact <- function(x) Filter(Negate(is.null), x)
