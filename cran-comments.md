This is a patch release to fix check CRAN check errors for lutz 0.3.0 on osx: https://cran.r-project.org/web/checks/check_results_lutz.html

## Test environments
* Local macOS install (Mojave 10.14.5 ), R 3.6.1
* win-builder (R-devel)
* Ubuntu 14.04.5 (on Travis-CI: R-devel, R-release and R-oldrel)
* OS X 10.13.3 (on Travis-CI; R-release) 
* Debian Linux, R-devel, GCC ASAN/UBSAN (r-hub)
* Fedora Linux, R-devel, clang, gfortran (r-hub)
* Windows Server 2012 R2 x64 (on Appveyor - R 3.6.1)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There is one reverse Suggests: weathercan. I ran `R CMD check` on it with this version of lutz (0.3.1) and there were no issues
