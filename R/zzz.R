lutz_env <- new.env(parent = emptyenv())

.onLoad <- function(...) {
  assign("olson_names", OlsonNames(), envir = lutz_env) #nocov
}
