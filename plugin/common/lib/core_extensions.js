
if (! Function.prototype.bind)
  Function.prototype.bind = function(scope) {
    var _function = this;
    return function() {
      return _function.apply(scope, arguments);
    };
  };

// if (! Object.prototype.keys)
//   Object.prototype.keys = function () {
//     var res = [];
//     for (var k in this) {
//       if (this.hasOwnProperty(k))
//         res.push(k);
//     }
//     return res;
//   };

// if (! Object.prototype.values)
//   Object.prototype.values = function () {
//     var res = [];
//     for (var k in this) {
//       if (this.hasOwnProperty(k))
//         res.push(this[k]);
//     }
//     return res;
//   };

// if (! Object.prototype.map)
//   Object.prototype.map = function (fct) {
//     var res = [];
//     for (var k in this) {
//       if (this.hasOwnProperty(k))
//         res.push(fct(k, this[k]));
//     }
//     return res;
//   };

// $.extend from jQuery
function $extend() {
  var options, name, src, copy, copyIsArray, clone,
    target = arguments[0] || {},
    i = 1,
    length = arguments.length,
    deep = true;
  // Handle case when target is a string or something (possible in deep copy)
  if ( typeof target !== "object" && typeof target !== "function" ) {
    target = {};
  }
  for ( ; i < length; i++ ) {
    // Only deal with non-null/undefined values
    if ( (options = arguments[ i ]) !== null ) {
      // Extend the base object
      for ( name in options ) {
        src = target[ name ];
        copy = options[ name ];

        // Prevent never-ending loop
        if ( target === copy ) {
          continue;
        }

        // Recurse if we're merging plain objects or arrays
        if ( deep && copy && ( (copyIsArray = Array.isArray(copy)) || typeof copy === "object" ) ) {
          if ( copyIsArray ) {
            copyIsArray = false;
            clone = src && Array.isArray(src) ? src : [];

          } else {
            clone = src && typeof src === "object" ? src : {};
          }

          // Never move original objects, clone them
          target[ name ] = $extend( clone, copy );

        // Don't bring in undefined values
        } else if ( copy !== undefined ) {
          target[ name ] = copy;
        }
      }
    }
  }

  // Return the modified object
  return target;
}

// Return a new ary with uniq values, base on values return by fct for each item if defined.
function $unique(ary, fct){
  var r = [], values = [], i;
  if (typeof fct === 'function') {
    for(i = 0; i < ary.length; i++){
      var val = fct(ary[i]);
      if( values.indexOf(val) == -1 ) {
        r.push( ary[i] );
        values.push(val);
      }
    }
  } else {
    for(i = 0; i < ary.length; i++){
      if( r.indexOf(ary[i]) == -1 )
        r.push( ary[i] );
    }
  }
  return r;
}

// NodeJS support
if (typeof global !== 'undefined') {
  global.$extend = $extend;
  global.$unique = $unique;
}
