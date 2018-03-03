#' Lookup time zones of sf or sp points
#'
#' This can very quickly look up the time zone of many thousands of points,
#' however the underlying time zone map has been simplified to allow for this speed.
#' As such when a point is near a time zone boundary and not near a populated centre,
#' it may return the incorrect timezone. If accuracy is more important than speed,
#' try [tz_lookup2()].
#'
#' @param x either an `sfc` or `sf` points or `SpatialPoints(DataFrame)` object
#' @param crs the coordinate reference system: integer with the EPSG code, or character with proj4string.
#' If not specified (i.e., `NULL`) and `x` has no existing `crs`, EPSG: 4326 is assumed (lat/long).
#'
#' @return character vector the same length as `x` specifying the time zone of the points.
#' @export
#'
#' @examples
#' if (require("sf")) {
#'
#' state_pts <- lapply(seq_along(state.center$x), function(i) {
#'   st_point(c(state.center$x[i], state.center$y[i]))
#' })
#'
#' state_centers_sf <- st_sf(st_sfc(state_pts))
#'
#' state_centers_sf$tz <- tz_lookup(state_centers_sf)
#'
#' plot(state_centers_sf[, "tz"])
#' }
#'
tz_lookup <- function(x, crs = NULL) {
  UseMethod("tz_lookup")
}

#' @export
tz_lookup.sf <- function(x, crs = NULL) {
  x <- fix_sf(x, crs)

  coords <- sf::st_coordinates(x)
  # sf stores as x, y and tzlookup likes lat, lon (Which is the opposite)
  tz_lookup_coords(lat = coords[, 2], lon = coords[, 1])
}

#' @export
tz_lookup.sfc <- tz_lookup.sf

#' @export
tz_lookup.SpatialPoints <- function(x, crs = NULL) {
  x <- fix_sp(x, crs)

  coords <- sp::coordinates(x)
  # sf stores as x, y and tzlookup likes lat, lon (Which is the opposite)
  tz_lookup_coords(lat = coords[, 2], lon = coords[, 1])
}

#' Lookup time zones of lat/long pairs
#'
#' This can very quickly look up the time zone of many thousands of points,
#' however the underlying time zone map has been simplified to allow for this speed.
#' As such when a point is near a time zone boundary and not near a populated centre,
#' it may return the incorrect timezone. If accuracy is more important than speed,
#' try [tz_lookup_coords2()].
#'
#' @param lat numeric vector of latitudes
#' @param lon numeric vector of longitudes the same length as `x`
#'
#' @return character vector the same length as x and y specifying the time zone of the points.
#' @export
#'
#' @examples
#' tz_lookup_coords(42, -123)
#' tz_lookup_coords(lat = c(48.9, 38.5, 63.1, -25), lon = c(-123.5, -110.2, -95.0, 130))
tz_lookup_coords <- function(lat, lon) {
  if (inherits(lat, c("sf", "sfc", "SpatialPoints"))) {
    stop("It looks like you are trying to get the tz of an sf/sfc or SpatialPoints object! Use tz_lookup() instead.",
         call. = FALSE)
  }

  check_coords(lat, lon)

  ctx <- make_ctx()

  ctx$assign("lat", lat)
  ctx$assign("lon", lon)
  ctx$eval("var out = Rtzlookup(lat, lon);")
  ret <- ctx$get("out")
  if (is.null(ret)) ret <- NA_character_
  ret
}

is_wgs84 <- function(x) {
  # The most minimal specification of WGS84
  comp <- c("+proj=longlat", "+datum=WGS84", "+no_defs")
  x_str <- strsplit(sp::CRS(sp::proj4string(x))@projargs, " +")[[1]]
  all(comp %in% x_str)
}

fix_sp <- function(x, crs) {
  if (!requireNamespace("sp"))
    stop("You must have the sp package installed to use this function", call. = FALSE)

  if (is.numeric(crs)) crs <- paste0("+init=epsg:", crs)

  if (is.na(sp::proj4string(x))) {
    if (is.null(crs)) crs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    sp::proj4string(x) <- sp::CRS(crs)
  }

  if (!is_wgs84(x)) {
    x <- sp::spTransform(x, sp::CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
  }
  x
}

fix_sf <- function(x, crs) {
  if (!requireNamespace("sf"))
    stop("You must have the sf package installed to use this function", call. = FALSE)

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

#' A more accurate (but slower) version of tz_lookup
#'
#' @inheritParams tz_lookup
#'
#' @inherit tz_lookup return
#' @export
tz_lookup2 <- function(x, crs) {
  UseMethod("tz_lookup2")
}

#' @export
tz_lookup2.sf <- function(x, crs = NULL) {
  x <- fix_sf(x, crs)
  x <- suppressMessages(sf::st_join(x, tz_sf))
  ret <- x$tzid

  # If any are NA (probably ocean), try to fill in with V8-based tzlookup
  nas <- which(is.na(ret))
  if (!length(nas)) {
    return(ret)
  }
  ret[nas] <- tz_lookup(x[nas, ])
  ret
}

#' @export
tz_lookup2.sfc <- function(x, crs = NULL) {
  x_sf <- sf::st_sf(id = seq_len(length(x)), geom = x)
  tz_lookup2(x_sf, crs = crs)
}

#' @export
tz_lookup2.SpatialPoints <- function(x, crs) {
  x <- sf::st_as_sf(x)
  tz_lookup2(x, crs)
}

#' More accurate (but slower) version of `tz_lookup_coords`
#'
#' @inheritParams tz_lookup_coords
#'
#' @inherit tz_lookup_coords return description
#' @export
tz_lookup_coords2 <- function(lat, lon) {
  ll <- data.frame(lat = lat, lon = lon)
  ll_sf <- sf::st_as_sf(ll, coords = c("lon", "lat"), crs = 4326)
  tz_lookup2(ll_sf)
}
