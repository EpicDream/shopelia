//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-24

define(["sprintf"], function(sprintf) {

var logger = {
  level: 3,
  // server_level: 0,

  NONE: 0,
  PRINT: 0.5,
  FATAL: 1,
  ERROR: 1,
  WARN: 2,
  WARNING: 2,
  INFO: 3,
  VERB: 4,
  VERBOSE: 4,
  DEBUG: 5,
  ALL: 6,

  code2str: {
    0: "NONE",
    "0.5": "PRINT",
    1: "ERROR",
    2: "WARN",
    3: "INFO",
    4: "VERB",
    5: "DEBUG",
    6: "ALL",
  },
};

//(arguments.callee.caller || {}).name
logger.fatal = function() { logger._log('FATAL', arguments); };
logger.err = function() { logger._log('ERROR', arguments); };
logger.error = logger.err;
logger.warn = function() { logger._log('WARN', arguments); };
logger.warning = logger.warn;
logger.good = function() { logger._log('GOOD', arguments); };
logger.info = function() { logger._log('INFO', arguments); };
logger.verbose = function() { logger._log('VERB', arguments); };
logger.debug = function() { logger._log('DEBUG', arguments); };
logger.print = function() { logger._log('PRINT', arguments); };

logger.isFatal = function() { return this.level >= this.FATAL; };
logger.isError = function() { return this.level >= this.ERROR; };
logger.isErr = logger.isError;
logger.isWarn = function() { return this.level >= this.WARN; };
logger.isWarning = logger.isWarn;
logger.isGood = function() { return this.level >= this.GOOD; };
logger.isInfo = function() { return this.level >= this.INFO; };
logger.isVerbose = function() { return this.level >= this.VERBOSE; };
logger.isDebug = function() { return this.level >= this.DEBUG; };

logger.timestamp = function (date) {
  date = new Date(date || Date.now());
  console.assert(typeof date === 'object' && date instanceof Date, 'date must be a Date');
  return sprintf("%s.%03d", date.toLocaleTimeString(), date.getMilliseconds());
};

logger.header = function (level, date) {
  console.assert(typeof level === 'string', 'level must be a string');
  var d = (date && new Date(date)) || new Date();
  return ['[%s][%5s]',logger.timestamp(d), level];
};

logger.format = function(level, args) {
  console.assert(typeof level === 'string', 'level must be a string');
  console.assert(typeof args === 'object' && args instanceof Array, 'args must be an Array');
  var res = level != "PRINT" ? logger.header(level) : [""];

  for ( i = 0 ; i < args.length ; i++ ) {
    arg = args[i];
    if (arg === undefined || arg === null) {
      res[0] += " %s";
    } else if (typeof arg === 'string' || typeof arg === 'number' || typeof arg === 'boolean') {
      res[0] += " %s";
    } else if (typeof arg === 'object' && arg instanceof RegExp) {
      res[0] += " %s";
    } else if (typeof arg === 'object' && arg instanceof Date) {
      res[0] += " %s";
    } else if (typeof arg === 'object' && arg instanceof HTMLElement) {
      res[0] += " %s";
      res.push( " HTMLElement." + arg.tagName );
      continue;
    } else {
      try {
        res[0] += " %s";
        res.push( JSON.stringify(arg).replace(/\%/g, '%%') );
        continue;
      } catch(err) {
        arg = "<<!! Logger.format: " + err + " !!>>";
        res[0] += " %s";
      }
    }
    res.push(arg);
  }

  return res;
};

logger.stringify = function(args) {
  console.assert(typeof args === 'object' && args instanceof Array, 'args must be an Array');
  return sprintf.apply(null, args);
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
    case 'PRINT' :
      if (logger.level >= logger.NONE)
        console.info.apply(console, args);
      break;
    default :
      if (logger.level >= logger.INFO)
        console.info.apply(console, args);
      break;
  }
};

logger._log = function(level, args) {
  var tmp, i, argsArray;

  if (logger[level] > logger.level)
    return;

  if (typeof args !== 'object' || args.length === undefined) {
    args = [args];
  } else if (! (args instanceof Array)) { // arguments is not an Array.
    tmp = [];
    for (i = 0; i < args.length; i++)
      tmp.push(args[i]);
    args = tmp;
  }
  console.assert(typeof level === 'string', 'level must be a string');
  console.assert(typeof args === 'object' && args instanceof Array, 'args must be an Array');

  try { return logger._log2(level, args); }
  catch(err) { return []; }
};

// No argument check
logger._log2 = function(level, args) {
  argsArray = logger.format(level, args);
  if (logger[level] <= logger.level)
    logger.write(level, argsArray);

  return argsArray;
};

////////////////////////////////////////
//          LOG TO SERVER
////////////////////////////////////////

// logger.req = new XMLHttpRequest();
// logger.req.open('POST', 'https://www.shopelia.com/api/viking/logs', false);
// logger.writeToServer = function (args) {
//   // logger.req.send(args);
// };

return logger;

});
