# lutz 0.3.2

This is a maintenance release, with no new features. The rgdal package was 
removed as a Suggested package, as it has been archived on CRAN.

# lutz 0.3.1

* Fixed bug where invalid timezones would cause `tz_list()` to fail.

# lutz 0.3.0

* V8-based 'fast' method was ported to use Rcpp - it is now even faster, and
  we can drop the V8 dependency. Thanks @hrbrmstr! (#4)
* Bob Rudis (@hrbrmstr) added as an author
* Upgraded time zone map to 2019b
* Dealt with areas with overlapping time zones (#2)
* Added three new functions:
  - tz_list() lists all time zones and information about UTC offsets and daylight savings
  - tz_offset() lists information about a specific time in a specific time zone
  - tz_plot() plots a time zone and its UTC offset for a year, including periods
  of daylight savings.

# lutz 0.2.0

* Added `method = "accurate"` to do a slower, but more accurate lookup.
* Updated timezone map

# lutz 0.1.0

* Initial release
