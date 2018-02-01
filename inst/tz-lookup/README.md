To add the browserified tz-lookup.js library to the package:

```
npm install -g browserify
npm install tz-lookup
echo "global.tzlookup = require('tz-lookup');" > in.js
browserify in.js -o inst/tz-lookup/tz-lookup-browserify.js
rm -r in.js node_modules package-lock.json 
```
