This release is primarily to address three issues identified on CRAN:

* Remove archived package rgdal from Suggests
* Remove C++11 specification from DESCRIPTION
* Remove LazyData: true from DESCRIPTION

## R CMD check results

0 errors | 0 warnings | 1 note

There was 1 NOTE on my local macOS machine: 

```
Checking installed package size ... NOTE
  installed size is  5.5Mb
  sub-directories of 1Mb or more:
    R   5.0Mb
```

The spatial data for looking up time zones has been simplified as much as possible, 
balancing size and accuracy. I cannot reduce the size further without sacrificing
the accuracy of the time zone boundaries to an unacceptable level. This has not changed since the previous release.

## revdepcheck results

We checked 7 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages

