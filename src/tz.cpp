#include <cstdint>

#include <Rcpp.h>

using namespace Rcpp;

#include "generated-vars.h"

std::vector< std::string > TZLIST(_TZLIST, _TZLIST + sizeof(_TZLIST)/sizeof(_TZLIST[0]));

// [[Rcpp::export]]
Rcpp::CharacterVector timezone_lookup_coords_rcpp(Rcpp::NumericVector latv, Rcpp::NumericVector lonv) {

  Rcpp::CharacterVector out(latv.size());
  double lat, lon;
  uint32_t n, u, v, i;
  double x, y;

  for (R_xlen_t j=0; j<latv.size(); j++) {

    if (NumericVector::is_na(latv[j]) || NumericVector::is_na(lonv[j])) {
      out[j] = NA_STRING;
      continue;
    }

    lat = latv[j];
    lon = lonv[j];

    if (!(lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180)) return(R_NilValue);

    if (lat >= 90) {
      out[j] = "Etc/GMT";
      continue;
    }

    n = -1;
    x = (180 + lon) * 48 / 360.00000000000006;
    y = ( 90 - lat) * 24 / 180.00000000000003;
    u = static_cast<uint32_t>(floor(x))|0;
    v = static_cast<uint32_t>(floor(y))|0;
    i = v * 96 + u * 2;

    i = static_cast<uint32_t>(TZDATA[i]) * 56 + static_cast<uint32_t>(TZDATA[i + 1]) - 1995;

    while (i + TZLIST.size() < 3136) {

      // Increment the node pointer.
      n = n + i + 1;

      // Find where we are relative to the child node.
      x = static_cast<uint32_t>(floor((x - u) * 2)) % 2;
      y = static_cast<uint32_t>(floor((y - v) * 2)) % 2;
      u = static_cast<uint32_t>(floor(x))|0;
      v = static_cast<uint32_t>(floor(y))|0;

      // Read the child node.
      i = n * 8 + v * 4 + u * 2 + 2304;
      i = static_cast<uint32_t>(TZDATA[i]) * 56 + static_cast<uint32_t>(TZDATA[i + 1]) - 1995;

    }

    out[j] = TZLIST[i + TZLIST.size() - 3136];

  }

  return(out);

}
