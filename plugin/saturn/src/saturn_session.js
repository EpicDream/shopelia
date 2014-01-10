//
// Author : Vincent Renaudineau
// Created at : 2013-09-05

define(['logger', './saturn_options', 'helper', 'core_extensions', 'satconf'], function(logger, SaturnOptions, Helper) {
"use strict";

// Je fais la supposition simpliste mais réaliste que pour un produit,
// il y a le même nombre d'option quelque soit l'option choisie.

var SaturnSession = function(saturn, prod) {
  $extend(this, prod);
  this.saturn = saturn;
  this.canSubTask = false;

  this.id = ++SaturnSession.counter;
  this.prod_id = prod.id;
  this.strategy = this.strategy || 'normal';
  this.argOptions = this.argOptions || {};
  this.initialStrategy = this.strategy;
  this.options = new SaturnOptions(this.mapping, this.argOptions);

  this.rescueTimeout = undefined;
  this.results = []; // store each version's result.

  this.helper = Helper.get(prod.url, 'session');
  if (this.helper && this.helper.init)
    this.helper.init(this);
};

SaturnSession.counter = 0;

SaturnSession.prototype.start = function() {
  logger.info(this.logId(), "Start crawling '"+this.url+"' !");
  this.startTime = Date.now();
  this.rescueTimeout = setTimeout(this.onTimeout.bind(this), satconf.DELAY_RESCUE);
  this.openUrl();
};

SaturnSession.prototype.next = function() { try {
  var t;
  clearTimeout(this.rescueTimeout);
  this.rescueTimeout = setTimeout(this.onTimeout.bind(this), satconf.DELAY_RESCUE);
  switch (this.strategy) {
    case "superFast":
      this.strategy = 'done';
      this.crawl();
      break;
    case "fast" :
    case "normal" :
      t = this.options.next({lookInMapping: true, depthOnly: true});
      if (t !== null) {
        if (t[1] === undefined) {
          this.getOptions(t[0]);
        } else if (! t[1].selected) {
          this.setOption(t[0], t[1]);
        } else
          this.next();
      } else {
        var nbOption = this.options.currentNbOption() - Object.keys(this.argOptions).length;
        if (this.strategy === 'fast') {
          this.strategy = 'done';
        } else if (nbOption > 0 && ! this._subTaskId && ! this.batch_mode) {
          this.strategy = 'options';
        } else if (nbOption > 0) {
          this.strategy = 'full';
        } else
          this.strategy = 'done';
        this.crawl();
      }
      break;

    case "options" :
      if (this.canSubTask)
        this.createSubTasks();
      this.strategy = 'full';
      this.next();
      break;

    case "full" :
      if (this._depthOnly === undefined)
        this._depthOnly = true;
      t = this.options.next({lookInMapping: true, depthOnly: this._depthOnly});
      // on est arrivé à l'option la plus profonde, on crawl et on remonte.
      if (t === null && this._depthOnly) {
        this._depthOnly = false;
        if (this.options.currentNode().version)
          this.next();
        else
          this.crawl();
      // on cherchait une autre option, mais il n'y en a vraiment plus, on a fini.
      } else if (t === null) {
        this.strategy = 'done';
        this.next();
      // t !== null, on a une option à getter/setter.
      } else {
        this._depthOnly = true;
        if (t[1] === undefined) {
          this.getOptions(t[0]);
        } else
          this.setOption(t[0], t[1]);
      }
      break;

    case "done" :
      this.sendFinalVersions();
      break;

    case "ended" :
      logger.warn(this.logId(), "SaturnSession.next called with strategy == 'ended'.");
      break;
  }
} catch (err) {
  logger.error(this.logId(), "in next :", err);
}};

SaturnSession.prototype.retryLastCmd = function () {
  clearTimeout(this.rescueTimeout);
  this.rescueTimeout = setTimeout(this.onTimeout.bind(this), satconf.DELAY_RESCUE);
  if (! this.lastCmd)
    return;
  switch (this.lastCmd.action) {
    case "openUrl":
      this.openUrl(this.lastCmd.url);
      break;
    case "getOptions":
      this.getOptions(this.lastCmd.option);
      break;
    case "setOption":
      this.setOption(this.lastCmd.option, this.lastCmd.value);
      break;
    case "crawl":
      this.crawl();
      break;
    default:
      break;
  }
};

SaturnSession.prototype.createSubTasks = function() {
  var firstOption = this.options.firstOption({nonAlone: true}),
      option, hashes;
  if (! firstOption) // Possible if there is only a single choice
    return;
  option = firstOption.depth()+1;
  hashes = Object.keys(firstOption._childrenH);
  this._subTasks = {};
  for (var i = 1 ; i < hashes.length ; i++) {
    var hashCode = hashes[i];
    var prod = {
      id: this.prod_id,
      batch_mode: true,
      url: this.url,
      mapping: this.mapping, //Sharing
      merchant_id: this.merchant_id,
      strategy: 'normal',
      argOptions: $extend(true, {}, this.options.argOptions),
      _onSubTaskFinished: this.subTaskEnded.bind(this),
      _subTaskId: hashCode,
    };
    prod.argOptions[option] = hashCode;
    this._subTasks[hashCode] = prod;
    firstOption.removeChild(firstOption.childAt(hashCode));
    this.saturn.addProductToQueue(prod);
  }
  this.options.argOptions[option] = hashes[0];
};

SaturnSession.prototype.getOptions = function(option) {
  this.lastCmd = {action: "getOptions", mapping: this.mapping, option: option};
  this.evalAndThen(this.lastCmd, function(values) { try {
    logger.verbose(this.logId(), (! (values instanceof Array) && '?' || values.length)+" versions for option"+option);
    // logger.debug(values);
    if (! values)
      return this.fail("No options return for getOptions(option="+option+")");
    this.options.setValues(values);
    this.next();
  } catch (err) {
    this.fail("Bug during getOptions callback :", err);
  }}.bind(this));
};

SaturnSession.prototype.setOption = function(option, value) {
  this.lastCmd = {action: "setOption", mapping: this.mapping, option: option, value: value};
  this.evalAndThen(this.lastCmd);
};

SaturnSession.prototype.crawl = function() {
  this.lastCmd = {action: "crawl", mapping: this.mapping};
  this.evalAndThen(this.lastCmd, function(version) { try {
    var d = this;
    if (typeof version !== 'object')
      return this.fail("No result return for crawl");
    logger.info(this.logId(), "Parse results : ", '{name="'+version.name+
      '", avail="'+version.availability+'", price="'+version.price+'"}');

    if (Object.keys(version).length > 0) {
      this.options.setCurrentVersion(version);
      this.sendPartialVersion();
    }

    this.next();
  } catch (err) {
    this.fail("Bug during crawling callback :", err);
  }}.bind(this));
};

//
SaturnSession.prototype.subTaskEnded = function(subSession) {
  if (this.rescueTimeout) {
    clearTimeout(this.rescueTimeout);
    this.rescueTimeout = setTimeout(this.onTimeout.bind(this), satconf.DELAY_RESCUE * 5);
  }
  delete this._subTasks[subSession._subTaskId];
  this.results = this.results.concat(subSession.results);
  if (Object.keys(this._subTasks).length === 0) {
    delete this._subTasks;
    if (this.strategy === 'done' || this.strategy === 'ended')
      // last subtask ended, send final result.
      this.sendFinalVersions();
    // else, this subtask is not yet ended,
    // it will call finalVersion naturally when done.
  }
};

//
SaturnSession.prototype.sendPartialVersion = function() {
  var currentV = this.options.currentVersion();
  // Only if this is not the first version
  if (this._subTaskId || this._firstVersion)
    this.sendResult({versions: [currentV], options_completed: false});
  else
    this._firstVersion = currentV;
};

// 
SaturnSession.prototype.sendFinalVersions = function() {
  if (this._subTasks) {
    logger.info(this.logId(), "Main subTask finished, wait for others...");
    this.preEndSession();
  } else if (this._subTaskId !== undefined) {
    logger.info(this.logId(), "SubTask finished !");
    this._onSubTaskFinished(this);
    this.endSession();
  } else {
    this.sendResult({versions: [this._firstVersion], options_completed: true}); //
    logger.info(this.logId(), "Finish crawling ! ("+(Date.now()-this.startTime)+" ms)");
    this.endSession();
  }
};

//
SaturnSession.prototype.preEndSession = function() {
  clearTimeout(this.rescueTimeout);
  this.rescueTimeout = setTimeout(this.onTimeout.bind(this), satconf.DELAY_RESCUE * 5);
  this.strategy = 'ended'; // prevent
};

//
SaturnSession.prototype.endSession = function() {
  this.strategy = 'ended'; // prevent
  clearTimeout(this.rescueTimeout);
  this.saturn.endSession(this);
};

//
SaturnSession.prototype.onTimeout = function() {
  this.fail("Session Timeout !");
};

//
SaturnSession.prototype.logId = function () {
  var s = this.id ? '#'+this.id : '';
  s += this.prod_id ? '/'+this.prod_id : '';
  return s;
};

////////////////////////////////////////////////////

// Virtual, must be reimplement.
SaturnSession.prototype.openUrl = function(url) {
  this.lastCmd = {action: "openUrl", url: url};
};

// Virtual, must be reimplement.
SaturnSession.prototype.evalAndThen = function(cmd, callback) {
  throw "SaturnSession.evalAndThen: abstract function";
};

SaturnSession.prototype.fail = function(msg) {
  this.sendError(msg);
  if (typeof this._onSubTaskFinished === 'function')
    this._onSubTaskFinished(this);
  this.endSession();
};

// Virtual, must be reimplement.
SaturnSession.prototype.sendWarning = function(msg) {
  this.$e = msg;
  logger.warn(this.logId(), msg, "\n$e =", this.$e);
};

// Virtual, must be reimplement.
SaturnSession.prototype.sendError = function( msg) {
  this.$e = msg;
  logger.err(this.logId(), msg, "\n$e =", this.$e);
};

// Virtual, must be reimplement.
SaturnSession.prototype.sendResult = function(result) {
  this.results.push(result);
};

return SaturnSession;

});
