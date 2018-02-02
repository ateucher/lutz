make_ctx <- function() {
  ctx <- V8::v8()
  ctx$source(system.file("tz-lookup/tz-lookup-browserify.js",
  ctx$source(system.file("Rtzlookup.js",
                         package = "lutz"))
  ctx
}
