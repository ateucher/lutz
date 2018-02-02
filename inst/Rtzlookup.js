function is_missing(x) {
  var missing = (typeof(x) === 'undefined' || typeof(x) !== 'number' || isNaN(x) || x === null);
  return missing;
}

function Rtzlookup(lat, lon) {
  if (Array.isArray(lat)) {
    var out = [];
    for (i = 0; i < lat.length; i++) {
      if (is_missing(lat[i]) || is_missing(lon[i])) {
        out.push(null);
      } else {
        out.push(tzlookup(lat[i], lon[i]));
      }
    }
  } else {
    if (is_missing(lat) || is_missing(lon)) {
      var out = null;
    } else {
      var out = tzlookup(lat, lon)
    }
  }
return out;
}
