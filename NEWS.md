# lutz 0.2.0.999

* V8-based 'fast' method was ported to use Rcpp - it is now even faster, and
  we can drop the V8 dependency. Thanks @hrbrmstr! (#4)
* Bob Rudis (@hrbrmstr) added as an author
* Upgraded timezone map to 2019b
* Dealt with areas with overlapping timezones (#2)

# lutz 0.2.0

* Added `method = "accurate"` to do a slower, but more accurate lookup.
* Updated timezone map

# lutz 0.1.0

* Initial release
