make_ctx <- function() {
  ctx <- V8::v8()
  ctx$source(system.file("tz-lookup/tz.js",
                         package = "lutz"))
  ctx$source(system.file("Rtzlookup.js",
                         package = "lutz"))
  ctx
}
