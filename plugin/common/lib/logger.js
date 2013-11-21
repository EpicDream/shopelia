//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-24

(function() {

var sprintf = window.sprintf;

var logger = {
  level: 3,
  server_level: 0,

  NONE: 0,
  FATAL: 1,
  ERROR: 1,
  WARN: 2,
  WARNING: 2,
  INFO: 3,
  DEBUG: 4,
  ALL: 5,

  code2str: {
    0: "NONE",
    1: "ERROR",
    2: "WARN",
    3: "INFO",
    4: "DEBUG",
    5: "ALL",
  },
};

logger.fatal = function() { logger._log('FATAL', (arguments.callee.caller || {}).name, arguments); };
logger.err = function() { logger._log('ERROR', (arguments.callee.caller || {}).name, arguments); };
logger.error = logger.err;
logger.warn = function() { logger._log('WARN', (arguments.callee.caller || {}).name, arguments); };
logger.good = function() { logger._log('GOOD', undefined, arguments); };
logger.info = function() { logger._log('INFO', undefined, arguments); };
logger.debug = function() { logger._log('DEBUG', (arguments.callee.caller || {}).name, arguments); };
logger.print = function() { if (logger.level !== logger.NONE) console.info.apply(console, arguments); };

logger.timestamp = function (date) {
  date = new Date(date || Date.now());
  console.assert(typeof date === 'object' && date instanceof Date, 'date must be a Date');
  return sprintf("%s.%03d", date.toLocaleTimeString(), date.getMilliseconds());
};

logger.header = function (level, caller, date) {
  var d = new Date(date || Date.now()),
    header = sprintf('[%s][%5s]%s',logger.timestamp(d), level, typeof caller === 'string' && caller !== "" ? " `"+caller+"' :" : '');
  console.assert(typeof level === 'string', 'level must be a string');
  console.assert(typeof caller === 'string', 'caller must be a string');
  console.assert(typeof d === 'object' && d instanceof Date, 'date must be a Date');
  return header;
};

logger.format = function(level, caller, args) {
  console.assert(typeof level === 'string', 'level must be a string');
  console.assert(typeof caller === 'string', 'caller must be a string');
  console.assert(typeof args === 'object' && args instanceof Array, 'args must be an Array');
  var res = [logger.header(level, caller)];

  for ( i = 0 ; i < args.length ; i++ ) {
    arg = args[i];
    if (typeof arg === 'string' || typeof arg === 'number' || typeof arg === 'boolean') {
      res[0] += " %s";
    } else if (typeof arg === 'object' && arg instanceof RegExp) {
      res[0] += " %s";
    } else if (typeof arg === 'object' && arg instanceof Date) {
      res[0] += " %s";
    } else if (typeof arg === 'object' && arg instanceof HTMLElement) {
      res[0] += " HTMLElement." + arg.tagName;
      continue;
    } else {
      try {
        res[0] += " " + JSON.stringify(arg).replace(/\%/g, '%%');
        continue;
      } catch(err) {
        res[0] += " ";
      }
    }
    res.push(arg);
  }

  return res;
};

logger.stringify = function(args) {
  console.assert(typeof args === 'object' && args instanceof Array, 'args must be an Array');
  return sprintf.apply({}, args);
};

logger.write = function (level, args) {
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

logger._log = function(level, caller, args) {
  var tmp, i, argsArray;

  caller = caller || '';
  if (typeof args !== 'object' || args.length === undefined) {
    args = [args];
  } else if (! (args instanceof Array)) { // arguments is not an Array.
    tmp = [];
    for (i = 0; i < args.length; i++)
      tmp.push(args[i]);
    args = tmp;
  }
  console.assert(typeof level === 'string', 'level must be a string');
  console.assert(typeof caller === 'string', 'caller must be a string');
  console.assert(typeof args === 'object' && args instanceof Array, 'args must be an Array');

  try { return logger._log2(level, caller, args); }
  catch(err) { return []; }
};

// No argument check
logger._log2 = function(level, caller, args) {
  argsArray = logger.format(level, caller, args);
  if (logger[level] <= logger.level)
    logger.write(level, argsArray);

  if (logger.server_level >= logger[level])
    logger.writeToServer(argsArray);
  return argsArray;
};

////////////////////////////////////////
//          LOG TO SERVER
////////////////////////////////////////

logger.req = new XMLHttpRequest();
logger.req.open('POST', 'https://www.shopelia.com/api/viking/logs', false);
logger.writeToServer = function (args) {
  // logger.req.send(args);
};

if ("object" == typeof module && module && "object" == typeof module.exports)
  module.exports = logger;
else if ("object" == typeof exports)
  exports = logger;
else if ("function" == typeof define && define.amd)
  define("logger", ['sprintf'], function(sprtf){sprintf = sprtf; return logger;});
else
  window.logger = logger;

})();
