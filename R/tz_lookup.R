#' Lookup timezones of points
#'
#' @param x either an `sfc` or `sf` points object
#' @param crs the coordinate reference system: integer with the EPSG code, or character with proj4string.
#' If not specified (i.e., `NULL`) and `x` has no existing `crs`, EPSG: 4326 is assumed (lat/long).
#'
#' @return character vector the same length as `x` specifying the Timezone of the points.
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
#' state_centers_sf$tz <- tz_lookup_sf(state_centers_sf)
#'
#' plot(state_centers_sf[, "tz"])
#' }
#'

#' @export
tz_lookup_sf <- function(x, crs = NULL) {
  if (!requireNamespace("sf"))
    stop("You must have the sf package installed to use this function", call. = FALSE)

  if (!inherits(x, c("sf", "sfc")))
    stop("x must of class sf or sfc")

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

  coords <- sf::st_coordinates(x)
  # sf stores as x, y and tzlookup likes lat, lon (Which is the opposite)
  tz_lookup(lat = coords[, 2], lon = coords[, 1])
}

#' Lookup timezones of points
#'
#' @param lat numeric vector of latitudes
#' @param lon numeric vector of longitudes the same length as `x`
#'
#' @return character vector the same length as x and y specifying the Timezone of the points.
#' @export
#'
#' @examples
#' tz_lookup(42, -123)
#' tz_lookup(lat = c(48.9, 38.5, 63.1, -25), lon = c(-123.5, -110.2, -95.0, 130))
tz_lookup <- function(lat, lon) {
  if (inherits(lat, c("sf", "sfc"))) {
    stop("It looks like you are trying to get the tz of an sf/sfc object! Use tz_lookup_sf() instead.",
         call. = FALSE)
  }

  if (!identical(length(lat), length(lon)) || !all(is.numeric(lat) && is.numeric(lon))) {
    stop("lat and lon must numeric vectors be of the same length")
  }

  ctx <- make_ctx()

  ctx$assign("lat", lat)
  ctx$assign("lon", lon)
  ctx$eval("
if (Array.isArray(lat)) {
  var out = [];
  for (i = 0; i < lat.length; i++) {
    out.push(tzlookup(lat[i], lon[i]));
  }
} else {
  var out = tzlookup(lat, lon)
}
")
  ctx$get("out")
}
