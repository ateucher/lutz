## Resubmission
This is a resubmission. In this version I have:

* fixed the condition causing the failing test ('tz_lookup.SpatialPoints: Error: no system list, errno: 2'). As far as I could discern this was only happening on Linux
* Enabled tests to catch the error

## Test environments
* local OS X install (Sierra 10.12.6), R 3.4.3
* win-builder (r-devel, r-release)
* ubuntu 14.04 (on Travis-CI: R-release and R-oldrel)
* Windows Server 2012 R2 x64 (on Appveyor - R 3.4.3 patched)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Reverse dependencies

This is a new release, so there are no reverse dependencies.
