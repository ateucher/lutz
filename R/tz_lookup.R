#' Lookup time zones of sf or sp points
#'
#' There are two methods - `"fast"`, and `"accurate"`. The `"fast"` version can
#' look up many thousands of points very quickly, however  when a point is near
#' a time zone boundary and not near a populated centre, it may return the
#' incorrect timezone. If accuracy is more important than speed, use
#' `method = "accurate"`.
#'
#' @param x either an `sfc` or `sf` points or `SpatialPoints(DataFrame)` object
#' @param crs the coordinate reference system: integer with the EPSG code, or character with proj4string.
#' If not specified (i.e., `NULL`) and `x` has no existing `crs`, EPSG: 4326 is assumed (lat/long).
#' @param method method by which to do the lookup. Either `"fast"` (default)
#' or `"accurate"`.
#' @param warn By default, if `method = "fast"` a warning is issued about
#'   the potential for inaccurate results. Set `warn` to `FALSE` to turn
#'   this off.
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
tz_lookup <- function(x, crs = NULL, method = "fast", warn = TRUE) {
  switch(method,
         fast = tz_lookup_fast(x, crs, warn),
         accurate = tz_lookup_accurate(x, crs),
         stop("method mst be one of 'fast' or 'accurate'", call. = FALSE))

}

tz_lookup_fast <- function(x, crs = NULL, warn) {
  UseMethod("tz_lookup_fast")
}

tz_lookup_fast.sf <- function(x, crs, warn) {
  x <- fix_sf(x, crs)
  coords <- sf::st_coordinates(x)
  # sf stores as x, y and tzlookup likes lat, lon (Which is the opposite)
  tz_lookup_coords_fast(lat = coords[, 2], lon = coords[, 1], warn = warn)
}

tz_lookup_fast.sfc <- tz_lookup_fast.sf

tz_lookup_fast.SpatialPoints <- function(x, crs, warn) {
  x <- fix_sp(x, crs)

  coords <- sp::coordinates(x)
  # sf stores as x, y and tzlookup likes lat, lon (Which is the opposite)
  tz_lookup_coords_fast(lat = coords[, 2], lon = coords[, 1], warn = warn)
}

#' Lookup time zones of lat/long pairs
#'
#' There are two methods - `"fast"`, and `"accurate"`. The `"fast"` version can
#' look up many thousands of points very quickly, however  when a point is near
#' a time zone boundary and not near a populated centre, it may return the
#' incorrect timezone. If accuracy is more important than speed, use
#' `method = "accurate"`.
#'
#' @param lat numeric vector of latitudes
#' @param lon numeric vector of longitudes the same length as `x`
#' @inheritParams tz_lookup
#' @return character vector the same length as x and y specifying the time zone of the points.
#' @export
#'
#' @examples
#' tz_lookup_coords(42, -123)
#' tz_lookup_coords(lat = c(48.9, 38.5, 63.1, -25), lon = c(-123.5, -110.2, -95.0, 130))
tz_lookup_coords <- function(lat, lon, method = "fast", warn = TRUE) {
  check_for_spatial(lat)
  check_coords(lat, lon)

  switch(method,
    fast = tz_lookup_coords_fast(lat, lon, warn),
    accurate = tz_lookup_coords_accurate(lat, lon),
    stop("method mst be one of 'fast' or 'accurate'", call. = FALSE)
  )
}

tz_lookup_coords_fast <- function(lat, lon, warn) {
  if (warn) warn_for_fast()
  ctx <- make_ctx()

  ctx$assign("lat", lat)
  ctx$assign("lon", lon)
  ctx$eval("var out = Rtzlookup(lat, lon);")
  ret <- ctx$get("out")
  if (is.null(ret)) ret <- NA_character_
  ret
}

tz_lookup_accurate <- function(x, crs = NULL) {
  UseMethod("tz_lookup_accurate")
}

tz_lookup_accurate.sf <- function(x, crs = NULL) {
  x <- fix_sf(x, crs)
  x <- suppressMessages(sf::st_join(x, tz_sf))
  ret <- x$tzid

  # If any are NA, try to fill in with V8-based tzlookup
  nas <- which(is.na(ret))
  if (!length(nas)) {
    return(ret)
  }
  ret[nas] <- tz_lookup_fast(x[nas, ], warn = FALSE)
  ret
}

tz_lookup_accurate.sfc <- function(x, crs = NULL) {
  x_sf <- sf::st_sf(id = seq_len(length(x)), geom = x)
  tz_lookup_accurate(x_sf, crs = crs)
}

tz_lookup_accurate.SpatialPoints <- function(x, crs = NULL) {
  x <- sf::st_as_sf(x)
  tz_lookup_accurate(x, crs)
}

tz_lookup_coords_accurate <- function(lat, lon) {

  ll <- data.frame(lat = lat, lon = lon)
  # check for NAs before converting to sf, only send valid lat/lon pairs
  # into sf, recombine with NAs for output
  cc <- stats::complete.cases(ll)
  ret <- rep(NA_character_, length(cc))
  if (sum(cc)) {
    ll_sf <- sf::st_as_sf(ll[cc, ], coords = c("lon", "lat"), crs = 4326)
    ret[cc] <- tz_lookup_accurate(ll_sf)
  }
  ret
}
