#' Lookup timezones of points
#'
#' @param x either an `sfc` or `sf` points object, or a numeric vector of x coordinates
#' @param y if `x` is a numeric vector of x coordinates, `y` must be a numeric vector of
#' y coordinates the same length as `x`. Ignored if `x` is an `sf` or `sfc` object.
#' @param crs the coordinate reference system: integer with the EPSG code, or character with proj4string.
#' If not specified (i.e., `NULL`) and `x` and `y` are numeric vectors, or `x` is an `sf` or `sfc` object
#' with no existing `crs`, EPSG: 4326 is assumed (lat/long).
#'
#' @return character vector the same length as specifying the Timezone of the points.
#' @export
#'
#' @examples
#' if (requireNamespace("sp")) {
#' data(meuse, package = "sp")
#'
#' # numeric:
#' tz_lookup(meuse$x, meuse$y, 28992)
#'
#' # With a sf object:
#' meuse_sf = sf::st_as_sf(meuse, coords = c("x", "y"), crs = 28992, agr = "constant")
#' tz_lookup(meuse_sf)
#' }
#'
tz_lookup <- function(x, y, crs = NULL) {
  UseMethod("tz_lookup")
}

#' @export
tz_lookup.sf <- function(x, y, crs = NULL) {
  if (!all(sf::st_geometry_type(x) == "POINT")) {
    stop("This only works with points")
  }

  if (is.na(sf::st_crs(x))) {
    if (is.null(crs)) crs <- 4326
    sf::st_crs(x) <- crs
  }

  transform <- sf::st_crs(x) != sf::st_crs(rtz::tz)
  if (transform) {
    x <- sf::st_transform(x, crs = sf::st_crs(rtz::tz))
  }
  intersect_ids <- suppressMessages(unlist(sf::st_intersects(x, rtz::tz)))
  rtz::tz$tzid[intersect_ids]
}

#' @export
tz_lookup.sfc <- tz_lookup.sf

#' @export
tz_lookup.numeric <- function(x, y, crs = NULL) {

  if (length(x) != length(y)) {
    stop("x and y must be of equal length")
  }

  if (is.null(crs)) {
    crs <- 4326
  }

  pts_list <- lapply(seq_along(x), function(i) {
    sf::st_point(c(x[i], y[i]))
  })

  pts <- sf::st_sfc(pts_list, crs = crs)
  tz_lookup(pts)
}
