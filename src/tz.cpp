#include <cstdint>

#include <Rcpp.h>

using namespace Rcpp;

#include "generated-vars.h"

std::vector< std::string > TZLIST(_TZLIST, _TZLIST + sizeof(_TZLIST)/sizeof(_TZLIST[0]));

// [[Rcpp::export]]
Rcpp::CharacterVector timezone_lookup_coords_rcpp(Rcpp::NumericVector latv, Rcpp::NumericVector lonv) {

  Rcpp::CharacterVector out(latv.size());

  double lat, lon;
  long n, u, v, i;
  double x, y;

  for (R_xlen_t j=0; j<latv.size(); j++) {

    // Handle NA's
    if (NumericVector::is_na(latv[j]) || NumericVector::is_na(lonv[j])) { // nocov start
      out[j] = NA_STRING;
      continue;
    } // nocov end

    lat = latv[j];
    lon = lonv[j];

    // Valid #'s ?
    if (!(lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180)) { // nocov start
      out[j] = NA_STRING;
      continue;
    } // nocov end

    if (lat >= 90) {   // Special case the north pole.
      out[j] = "Etc/GMT";
      continue;
    }

    // The tree is essentially a quadtree, but with a very large root node.
    // The root node is 48x24; the width is the smallest such that maritime
    // time zones fall neatly on it's edges (which allows better compression),
    // while the height is chosen such that nodes further down the tree are all
    // square (which is necessary for the properties of a quadtree to hold).

    // Node offset in the tree.

    n = -1;

    // Location relative to the current node. The root node covers the whole
    // earth (and the tree as a whole is in equirectangular coordinates), so
    // conversion from latitude and longitude is straightforward. The constants
    // are the smallest 64-bit floating-point numbers strictly greater than 360
    // and 180, respectively; we do this so that floor(x)<48 and floor(y)<24.
    // (It introduces a rounding error, but this is negligible.)

    x = (180.0 + lon) * 48.0 / 360.0000000000000568; // was 360.00000000000006 in js lib;
    y = ( 90.0 - lat) * 24.0 / 180.0000000000000284; // was 180.00000000000003 in js lib;

    // Integer coordinates of child node. x|0 is simply a (signed) integer
    // cast, which is the fastest way to do floor(x) in JavaScript when you
    // can guarantee 0<=x<2^31 (which we can).

    u = static_cast<uint32_t>(floor(x))|0;
    v = static_cast<uint32_t>(floor(y))|0;

    // Contents of the child node. The topmost values are reserved for leaf
    // nodes and correspond to the indices of TZLIST. Every other value is a
    // pointer to where the next node in the tree is.

    i = v * 96 + u * 2;

    i = ((static_cast<uint32_t>(TZDATA[i])) * 56) + (static_cast<uint32_t>(TZDATA[i + 1])) - 1995;

    // Recurse until we hit a leaf node.
    while (i + TZLIST.size() < 3136) {

      n = n + i + 1; // Increment the node pointer.

      // Find where we are relative to the child node.

      x = std::fmod((x - u) * 2.0, 2.0);
      y = std::fmod((y - v) * 2.0, 2.0);

      u = static_cast<uint32_t>(floor(x))|0;
      v = static_cast<uint32_t>(floor(y))|0;

      // Read the child node.

      i = (n * 8) + (v * 4) + (u * 2) + 2304;
      i = static_cast<uint32_t>(TZDATA[i]) * 56 + static_cast<uint32_t>(TZDATA[i + 1]) - 1995;

    }

    out[j] = TZLIST[i + TZLIST.size() - 3136];

  }

  return(out);

}
