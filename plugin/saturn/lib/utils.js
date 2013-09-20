
/*! sprintf.js | Copyright (c) 2007-2013 Alexandru Marasteanu <hello at alexei dot ro> | 3 clause BSD license */
(function(e){function r(e){return Object.prototype.toString.call(e).slice(8,-1).toLowerCase()}function i(e,t){for(var n=[];t>0;n[--t]=e);return n.join("")}var t=function(){return t.cache.hasOwnProperty(arguments[0])||(t.cache[arguments[0]]=t.parse(arguments[0])),t.format.call(null,t.cache[arguments[0]],arguments)};t.format=function(e,n){var s=1,o=e.length,u="",a,f=[],l,c,h,p,d,v;for(l=0;l<o;l++){u=r(e[l]);if(u==="string")f.push(e[l]);else if(u==="array"){h=e[l];if(h[2]){a=n[s];for(c=0;c<h[2].length;c++){if(!a.hasOwnProperty(h[2][c]))throw t('[sprintf] property "%s" does not exist',h[2][c]);a=a[h[2][c]]}}else h[1]?a=n[h[1]]:a=n[s++];if(/[^s]/.test(h[8])&&r(a)!="number")throw t("[sprintf] expecting number but found %s",r(a));switch(h[8]){case"b":a=a.toString(2);break;case"c":a=String.fromCharCode(a);break;case"d":a=parseInt(a,10);break;case"e":a=h[7]?a.toExponential(h[7]):a.toExponential();break;case"f":a=h[7]?parseFloat(a).toFixed(h[7]):parseFloat(a);break;case"o":a=a.toString(8);break;case"s":a=(a=String(a))&&h[7]?a.substring(0,h[7]):a;break;case"u":a>>>=0;break;case"x":a=a.toString(16);break;case"X":a=a.toString(16).toUpperCase()}a=/[def]/.test(h[8])&&h[3]&&a>=0?"+"+a:a,d=h[4]?h[4]=="0"?"0":h[4].charAt(1):" ",v=h[6]-String(a).length,p=h[6]?i(d,v):"",f.push(h[5]?a+p:p+a)}}return f.join("")},t.cache={},t.parse=function(e){var t=e,n=[],r=[],i=0;while(t){if((n=/^[^\x25]+/.exec(t))!==null)r.push(n[0]);else if((n=/^\x25{2}/.exec(t))!==null)r.push("%");else{if((n=/^\x25(?:([1-9]\d*)\$|\(([^\)]+)\))?(\+)?(0|'[^$])?(-)?(\d+)?(?:\.(\d+))?([b-fosuxX])/.exec(t))===null)throw"[sprintf] huh?";if(n[2]){i|=1;var s=[],o=n[2],u=[];if((u=/^([a-z_][a-z_\d]*)/i.exec(o))===null)throw"[sprintf] huh?";s.push(u[1]);while((o=o.substring(u[0].length))!=="")if((u=/^\.([a-z_][a-z_\d]*)/i.exec(o))!==null)s.push(u[1]);else{if((u=/^\[(\d+)\]/.exec(o))===null)throw"[sprintf] huh?";s.push(u[1])}n[2]=s}else i|=2;if(i===3)throw"[sprintf] mixing positional and named placeholders is not (yet) supported";r.push(n)}t=t.substring(n[0].length)}return r};var n=function(e,n,r){return r=n.slice(0),r.splice(0,0,e),t.apply(null,r)};e.sprintf=t,e.vsprintf=n})(typeof exports!="undefined"?exports:window);

// answered Jan 10 '11 at 23:45 by Tim Down (stackoverflow.com)
function getSelectionHtml() {
    var html = "";
    if (typeof window.getSelection != "undefined") {
        var sel = window.getSelection();
        if (sel.rangeCount) {
            var container = document.createElement("div");
            for (var i = 0, len = sel.rangeCount; i < len; ++i) {
                container.appendChild(sel.getRangeAt(i).cloneContents());
            }
            html = container.innerHTML;
        }
    } else if (typeof document.selection != "undefined") {
        if (document.selection.type == "Text") {
            html = document.selection.createRange().htmlText;
        }
    }
    return html;
};

if (! Function.prototype.bind)
  Function.prototype.bind = function(scope) {
    var _function = this;
    return function() {
      return _function.apply(scope, arguments);
    };
  };

if (! Array.prototype.unique)
  Array.prototype.unique = function(fct){
    var r = [], values = [];
    if (typeof fct === 'function') {
      for(var i = 0; i < this.length; i++){
        var val = fct(this[i]);
        if( values.indexOf(val) == -1 ) {
          r.push( this[i] );
          values.push(val);
        }
      }
    } else {
      for(var i = 0; i < this.length; i++){
        if( r.indexOf(this[i]) == -1 )
          r.push( this[i] );
      }
    }
    return r;
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
    if ( (options = arguments[ i ]) != null ) {
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
};

window.logger = window.logger || {};
window.logger._log = function(level, caller, _arguments) {
  var css_style;
  switch (level) {
    case 'FATAL' :
    case 'ERROR' :
      css_style = 'color: #f00';
      break;
    case 'WARN' :
    case 'WARNING' :
      level = 'WARN';
      css_style = 'color: #f60';
      break;
    case 'INFO' :
      css_style = 'color: #00f';
      break;
    case 'GOOD' :
      css_style = 'color: #090';
      break;
    case 'DEBUG' :
      css_style = 'color: #000';
      break;
    default:
      level = 'OTHER'
      css_style = 'color: #000';
      break;      
  }
  
  var args = [sprintf('%%c[%s][%5s]%s ',(new Date()).toLocaleTimeString(), level, typeof caller === 'string' ? " `"+caller+"' :" : ''), css_style];
  if (typeof _arguments !== 'object' || _arguments.length === undefined)
    args.push(_arguments);
  else for ( var i = 0 ; i < _arguments.length ; i++ ) {
    var arg = _arguments[i];
    if (typeof arg === 'number') {
      args[0] += "%f ";
    } else if (typeof arg === 'string') {
      args[0] += "%s ";
    } else if (typeof arg === 'object' && arg instanceof HTMLElement) {
      args[0] += "%o ";
    } else
      args[0] += "%O ";
    args.push(arg);
  }

  switch (level) {
    case 'FATAL' :
    case 'ERROR' :
      console.error.apply(console, args);
      break;
    case 'WARN' :
    case 'WARNING' :
      console.warn.apply(console, args);
      break;
    case 'DEBUG' :
      console.debug.apply(console, args);
      break;
    default :
      console.info.apply(console, args);
      break;
  }
};

window.logger.fatal = function _fatal() { logger._log('FATAL', (arguments.callee.caller || {}).name, arguments) };
window.logger.err = function _err() { logger._log('ERROR', (arguments.callee.caller || {}).name, arguments) };
window.logger.error = logger.err;
window.logger.warn = function _warn() { logger._log('WARN', (arguments.callee.caller || {}).name, arguments) };
window.logger.good = function _good() { logger._log('GOOD', undefined, arguments) };
window.logger.info = function _info() { logger._log('INFO', undefined, arguments) };
window.logger.debug = function _debug() { logger._log('DEBUG', (arguments.callee.caller || {}).name, arguments) };
