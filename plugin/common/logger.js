//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-24

(function() {

var sprintf = window.sprintf;

var logger = {
  level: 3,
  NONE: 0,
  ERROR: 1,
  WARN: 2,
  WARNING: 2,
  INFO: 3,
  DEBUG: 4,
  ALL: 5,
};

logger._log = function(level, caller, _arguments) {
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
      level = 'OTHER';
      css_style = 'color: #000';
      break;
  }
  
  var args;
  if (window.chrome)
    args = [sprintf('%%c[%s][%5s]%s ',(new Date()).toLocaleTimeString(), level, typeof caller === 'string' && caller !== "" ? " `"+caller+"' :" : ''), css_style];
  else
    args = [sprintf('[%s][%5s]%s ',(new Date()).toLocaleTimeString(), level, typeof caller === 'string' && caller !== "" ? " `"+caller+"' :" : '')]

  if (typeof _arguments !== 'object' || _arguments.length === undefined) {
    args.push(_arguments);
  } else if (! window.chrome) for ( var i = 0 ; i < _arguments.length ; i++ ) {
    args.push(_arguments[i]);
  } else for ( var i = 0 ; i < _arguments.length ; i++ ) {
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
      if (logger.level >= logger.ERROR)
        console.error.apply(console, args);
      break;
    case 'WARN' :
    case 'WARNING' :
      if (logger.level >= logger.WARNING)
        console.warn.apply(console, args);
      break;
    case 'DEBUG' :
      if (logger.level >= logger.DEBUG)
        console.debug.apply(console, args);
      break;
    default :
      if (logger.level >= logger.INFO)
        console.info.apply(console, args);
      break;
  }
};

logger.fatal = function() { logger._log('FATAL', (arguments.callee.caller || {}).name, arguments); };
logger.err = function() { logger._log('ERROR', (arguments.callee.caller || {}).name, arguments); };
logger.error = logger.err;
logger.warn = function() { logger._log('WARN', (arguments.callee.caller || {}).name, arguments); };
logger.good = function() { logger._log('GOOD', undefined, arguments); };
logger.info = function() { logger._log('INFO', undefined, arguments); };
logger.debug = function() { logger._log('DEBUG', (arguments.callee.caller || {}).name, arguments); };
logger.print = function() { if (logger.level !== logger.NONE) console.info.apply(console, arguments); };

if ("object" == typeof module && module && "object" == typeof module.exports)
  module.exports = logger;
else if ("object" == typeof exports)
  exports = logger;
else if ("function" == typeof define && define.amd)
  define("logger", ['sprintf'], function(sprtf){sprintf = sprtf; return logger;});
else
  window.logger = logger;

})();
