//
// Author : Vincent Renaudineau
// Created at : 2013-09-05

(function() {
"use strict";

// Je fais la supposition simpliste mais réaliste que pour un produit,
// il y a le même nombre d'option quelque soit l'option choisie.

var SaturnSession, that = SaturnSession = function(saturn, prod) {
  this.saturn = saturn;
  $extend(this, prod);

  this.strategy = this.strategy || 'normal';
  this.options = new SaturnOptions(this.mapping, this.argOptions);
};

that.prototype = {};

that.prototype.start = function() {
  logger.info((this.tabId ? '('+this.tabId+')' : '')+(this.id ? '{'+this.id+'}' : ''), "Start crawling !", this.TEST_ENV ? this : '');
  this.next();
};

that.prototype.next = function() {
  switch (this.strategy) {
    case "normal" :
      var t = this.options.next({lookInMapping: true, depthOnly: true});
      if (t !== null) {
        if (t[1] === undefined)
          this.getOptions(t[0]);
        else
          this.setOption(t[0], t[1]);
      } else {
        var nbOption = this.options.currentNbOption() - Object.keys(this.argOptions).length;
        if (nbOption > 0 && ! this._subTaskId) {
          this.strategy = 'options';
        } else if (nbOption == 1) {
          this.strategy = 'full';
        } else
          this.strategy = 'done';
        this.crawl();
      }
      break;

    case "options" :
      this.createSubTasks()
      this.strategy = 'full';
      this.next();
      break;

    case "full" :
      if (this._depthOnly === undefined)
        this._depthOnly = true;
      var t = this.options.next({depthOnly: this._depthOnly});
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
      // t !== null, on a une option à setter.
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
  }
};

that.prototype.createSubTasks = function() {
  var firstOption = this.options.firstOption({nonAlone: true}),
      option = firstOption.depth()+1,
      values = Object.keys(firstOption._childrenH);
  this._subTasks = {};
  for (var i = 1 ; i < values.length ; i++) {
    var value = values[i];
    var prod = {
      id: this.id,
      url: this.url,
      mapping: this.mapping, //Sharing
      merchant_id: this.merchant_id,
      strategy: 'normal',
      argOptions: $extend(true, {}, this.options.argOptions),
      _onSubTaskFinished: this.subTaskEnded.bind(this),
      _subTaskId: value,
    };
    prod.argOptions[option] = value;
    this.saturn.addProductToQueue(prod);
    this._subTasks[value] = prod;
    firstOption.removeChild(firstOption.childAt(value));
  }
  this.options.argOptions[option] = values[0];
};

that.prototype.getOptions = function(option) {
  this.currentAction = "getOptions";
  var cmd = {action: this.currentAction, mapping: this.mapping, option: option}
  this.saturn.evalAndThen(this, cmd, function(values) {
    logger.debug("in getOption, result :", values);
    if (! values)
      return this.saturn.sendError(this, "No options return for getOptions(option="+option+")");
    this.options.setValues(values);
    this.next();
  }.bind(this));
};

that.prototype.setOption = function(option, value) {
  this.currentAction = "setOption";
  var cmd = {action: this.currentAction, mapping: this.mapping, option: option, value: value};
  this.saturn.evalAndThen(this, cmd);
};

that.prototype.crawl = function() {
  this.currentAction = "crawl";
  this.saturn.evalAndThen(this, {action: this.currentAction, mapping: this.mapping}, function(version) {
    logger.debug("in crawl, result :", version);
    var d = this;
    if (! version)
      return sendError("No result return for crawl");

    if (Object.keys(version).length > 0) {
      this.options.setCurrentVersion(version);
      this.sendPartialVersion();
    }

    this.next();
  }.bind(this));
};

//
that.prototype.subTaskEnded = function(subSession) {
  delete this._subTasks[subSession._subTaskId];
  if (Object.keys(this._subTasks).length == 0) {
    delete this._subTasks;
    this.sendFinalVersions();
  }
};

//
that.prototype.sendPartialVersion = function() {
  var currentV = this.options.currentVersion();
  // Only if this is not the first version
  if (this._subTaskId || this._firstVersion)
    this.saturn.sendResult(this, {versions: [currentV], options_completed: false});
  else
    this._firstVersion = currentV;
};

// 
that.prototype.sendFinalVersions = function() {
  if (this._subTasks) {
    logger.info((this.tabId ? '('+this.tabId+')' : '')+(this.id ? '['+this.id+']' : ''), "SubTask finished, wait for others...", this.TEST_ENV ? this : '');
  } else if (typeof this._onSubTaskFinished === 'function') {
    logger.info((this.tabId ? '('+this.tabId+')' : '')+(this.id ? '{'+this.id+'}' : ''), "SubTask finished !", this.TEST_ENV ? this : '');
    this._onSubTaskFinished(this);
    this.endSession(this);
  } else {
    this.saturn.sendResult(this, {versions: [this._firstVersion], options_completed: true}); //
    logger.info((this.tabId ? '('+this.tabId+')' : '')+(this.id ? '{'+this.id+'}' : ''), "Finish crawling !", this.TEST_ENV ? this : '');
    this.endSession(this);
  }
};

//
that.prototype.endSession = function() {
  this.strategy = 'ended'; // prevent
  this.saturn.endSession(this);
};

if ("object" == typeof module && module && "object" == typeof module.exports)
  exports = module.exports = SaturnSession;
else if ("function" == typeof define && define.amd)
  define("saturn_session", ["saturn_options"], function(){return SaturnSession});
else
  window.SaturnSession = SaturnSession;

})();
