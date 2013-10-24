
if (! Function.prototype.bind)
  Function.prototype.bind = function(scope) {
    var _function = this;
    return function() {
      return _function.apply(scope, arguments);
    };
  };

if (! Array.prototype.unique)
  Array.prototype.unique = function(fct){
    var r = [], values = [], i;
    if (typeof fct === 'function') {
      for(i = 0; i < this.length; i++){
        var val = fct(this[i]);
        if( values.indexOf(val) == -1 ) {
          r.push( this[i] );
          values.push(val);
        }
      }
    } else {
      for(i = 0; i < this.length; i++){
        if( r.indexOf(this[i]) == -1 )
          r.push( this[i] );
      }
    }
    return r;
  };

if (! Array.prototype.groupBy)
  Array.prototype.groupBy = function (fct) {
    var i, v, result = {};
    this.forEach(function (e) {
      v = fct(e);
      result[v] = result[v] || [];
      result[v].push(e);
    });
    return result;
  };

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
