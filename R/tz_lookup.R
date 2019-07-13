#' Lookup time zones of sf or sp points
#'
#' There are two methods - `"fast"`, and `"accurate"`. The `"fast"` version can
#' look up many thousands of points very quickly, however  when a point is near
#' a time zone boundary and not near a populated centre, it may return the
#' incorrect time zone. If accuracy is more important than speed, use
#' `method = "accurate"`.
#'
#' Note that there are some regions in the world where a single point can land in
#' two different overlapping time zones. The `"accurate"` method includes these,
#' and when they are encountered they are concatenated in a single string,
#' separated by a semicolon.
#' The data used in the `"fast"` method does not include overlapping time zones
#' at this time.
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
         stop("method must be one of 'fast' or 'accurate'", call. = FALSE))

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
#' incorrect time zone. If accuracy is more important than speed, use
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
         stop("method must be one of 'fast' or 'accurate'", call. = FALSE)
  )
}

tz_lookup_coords_fast <- function(lat, lon, warn) {

  if (warn) warn_for_fast()

  timezone_lookup_coords_rcpp(lat, lon)

}

tz_lookup_accurate <- function(x, crs = NULL) {
  UseMethod("tz_lookup_accurate")
}

tz_lookup_accurate.sf <- function(x, crs = NULL) {
  x <- fix_sf(x, crs)
  # Add a unique id so we can deal with any duplicates resulting
  # from overlapping time zones
  x$lutzid <- seq_len(nrow(x))
  x_tz <- suppressMessages(sf::st_set_geometry(sf::st_join(x, tz_sf), NULL))

  # group x by lutzid and concatenate multiple time zones with ;
  if (nrow(x_tz) > nrow(x)) {
    warning("Some points are in areas with more than one time zone defined.",
            "These are often disputed areas and should be treated with care.")

    ret <- stats::aggregate(x_tz, list(x_tz$lutzid), function(x) {
      if (length(x) == 1) return(x)
      x <- paste(x, collapse = "; ")
    }, drop = FALSE)[["tzid"]]

  } else {
    ret <- x_tz$tzid
  }

  # If any are NA, try to fill in with Rcpp-based tzlookup
  nas <- which(is.na(ret))
  if (!length(nas)) {
    return(ret)
  }
  ret[nas] <- tz_lookup_fast(x[nas, ], warn = FALSE) # nocov start
  ret # nocov end
}

tz_lookup_accurate.sfc <- function(x, crs = NULL) {
  x_sf <- sf::st_sf(geom = x)
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
