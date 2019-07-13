# lutz 0.3.0

* V8-based 'fast' method was ported to use Rcpp - it is now even faster, and
  we can drop the V8 dependency. Thanks @hrbrmstr! (#4)
* Bob Rudis (@hrbrmstr) added as an author
* Upgraded timezone map to 2019b
* Dealt with areas with overlapping timezones (#2)
* Added three new functions:
  - tz_list() lists all timezones and information about UTC offsets and daylight savings
  - tz_offset() lists information about a specific time in a specific timezone
  - plot_tz() plots a timezone and its UTC offset for a year, including periods
  of daylight savings.

# lutz 0.2.0

* Added `method = "accurate"` to do a slower, but more accurate lookup.
* Updated timezone map

# lutz 0.1.0

* Initial release
