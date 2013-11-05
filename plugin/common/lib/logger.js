//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-24

(function() {

var sprintf = window.sprintf;

var logger = {
  level: 3,
  file_level: 5,
  server_level: 5,
  NONE: 0,
  ERROR: 1,
  WARN: 2,
  WARNING: 2,
  INFO: 3,
  DEBUG: 4,
  ALL: 5,
};

logger._log = function(level, caller, _arguments) {
  var d = new Date(),
    args = [sprintf('[%s][%5s]%s ',d.toLocaleTimeString() + '.' + d.getMilliseconds(), level, typeof caller === 'string' && caller !== "" ? " `"+caller+"' :" : '')],
    line = args[0],
    css_style, i, arg;

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
  
  if (window.chrome) {
    args[0] = "%c" + args[0];
    args.push(css_style);
  }

  if (typeof _arguments !== 'object' || _arguments.length === undefined) {
    args.push(_arguments);
    line += " " + _arguments;
  } else if (! window.chrome) for ( i = 0 ; i < _arguments.length ; i++ ) {
    args.push(_arguments[i]);
    line += _arguments[i];
  } else for ( i = 0 ; i < _arguments.length ; i++ ) {
    arg = _arguments[i];
    if (typeof arg === 'number') {
      args[0] += "%f ";
      line += " " + _arguments[i];
    } else if (typeof arg === 'string') {
      args[0] += "%s ";
      line += " " + _arguments[i];
    } else if (typeof arg === 'object' && arg instanceof HTMLElement) {
      args[0] += "%o ";
      line += " HTMLElement." + arg.tagName;
    } else {
      args[0] += "%O ";
      try { line += " " + JSON.stringify(_arguments[i]); } catch(err) {}
    }
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

  if (logger.file_level >= logger[level])
    logger.writeToFile(line);
  if (logger.server_level >= logger[level])
    logger.writeToServer(line);
};

logger.fatal = function() { logger._log('FATAL', (arguments.callee.caller || {}).name, arguments); };
logger.err = function() { logger._log('ERROR', (arguments.callee.caller || {}).name, arguments); };
logger.error = logger.err;
logger.warn = function() { logger._log('WARN', (arguments.callee.caller || {}).name, arguments); };
logger.good = function() { logger._log('GOOD', undefined, arguments); };
logger.info = function() { logger._log('INFO', undefined, arguments); };
logger.debug = function() { logger._log('DEBUG', (arguments.callee.caller || {}).name, arguments); };
logger.print = function() { if (logger.level !== logger.NONE) console.info.apply(console, arguments); };

////////////////////////////////////////
//          LOG TO FILE
////////////////////////////////////////

function errorHandler(e) {
  var msg = '';

  switch (e.code) {
    case FileError.QUOTA_EXCEEDED_ERR:
      msg = 'QUOTA_EXCEEDED_ERR';
      break;
    case FileError.NOT_FOUND_ERR:
      msg = 'NOT_FOUND_ERR';
      break;
    case FileError.SECURITY_ERR:
      msg = 'SECURITY_ERR';
      break;
    case FileError.INVALID_MODIFICATION_ERR:
      msg = 'INVALID_MODIFICATION_ERR';
      break;
    case FileError.INVALID_STATE_ERR:
      msg = 'INVALID_STATE_ERR';
      break;
    default:
      msg = 'Unknown Error';
      break;
  }

  console.error('Error: ' + msg);
}

logger.nbLine = 0;
logger.fileCtr = 0;

logger.openNewFile = function (callback) {
  var filename = "log-" + (new Date()).getTime() + ".txt";
  callback = callback || function () {};

  logger.nbLine = 0;
  logger.filesystem.root.getFile(filename, {create: true}, function(entry) {
    logger.fileEntry = entry;
  }, errorHandler);

  logger.removeOldFiles();
};

logger.removeOldFiles = function () {
  logger.filesystem.root.createReader().readEntries(function(entries) {
    var i, entries_tab = [];
    for (i = entries.length - 1; i >= 0; i--) {
      entries_tab.push(entries[i]);
    }
    entries = entries_tab.sort(function(e1, e2) {
      if (e1.name < e2.name) return -1;
      else if (e1.name > e2.name) return 1;
      else return 0;
    });

    var entry, m, min = entries.length - 10, d = new Date( new Date() - 1000 * 60 * 60 * 24 );
    for (i = 0; i < entries.length; i++) {
      entry = entries[i];
      m = entry.name.match(/log-\d+.txt/);
      if (i < min || m && parseInt(m, 10) < d) {
        entry.remove(function() {
          console.log(entry.name, "deleted.");
        });
      }
    }
  });
};

logger.writeToFile = function (line) {
  if (! logger.fileEntry) { return; }

  line += line.search(/\n$/) === -1 ? '\n' : '';

  logger.fileEntry.createWriter(function(fileWriter) {
    // Create a new Blob and write it to log.txt.
    var blob = new Blob([line], {type: 'text/plain'});
    fileWriter.seek(fileWriter.length);
    fileWriter.write(blob);

    logger.nbLine += 1;
    if (logger.nbLine > 1000)
      logger.openNewFile();
  }, errorHandler);
};

logger.printLastLogs = function () {
  logger.filesystem.root.createReader().readEntries(function(entries) {
    var i, entries_tab = [];
    for (i = entries.length - 1; i >= 0; i--) {
      entries_tab.push(entries[i]);
    }
    entries = entries_tab.sort(function(e1, e2) {
      if (e1.name < e2.name) return -1;
      else if (e1.name > e2.name) return 1;
      else return 0;
    });
    for (i = 0; i < entries.length; i++)
      entries[i].file(function(file) {
         var reader = new FileReader();
         reader.onloadend = function(e) {
           for (i = 0; i < entries.length; i++)
         };
         reader.readAsText(file);
      }, errorHandler);
  }, errorHandler);
};

if (window.webkitRequestFileSystem && window.Blob)
  window.webkitRequestFileSystem(window.TEMPORARY, 1*1024*1024 /*1MB*/, function onInitFs(fs) {
    logger.filesystem = fs;
    logger.openNewFile();
  }, errorHandler);

////////////////////////////////////////
//          LOG TO SERVER
////////////////////////////////////////

logger.req = new XMLHttpRequest();
logger.req.open('POST', 'https://www.shopelia.com/api/viking/logs', false);
logger.writeToServer = function (line) {
  // logger.req.send(line);
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
