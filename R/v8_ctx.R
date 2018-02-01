make_ctx <- function() {
  ctx <- V8::v8()
  ctx$source(system.file("tz-lookup/tz-lookup-browserify.js",
                         package = "lutz"))
  ctx
}
