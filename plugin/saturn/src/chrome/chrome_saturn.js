// ChromeSaturn
// Author : Vincent Renaudineau
// Created at : 2013-09-05

(function() {
"use strict";

var ChromeSaturn = function() {
  Saturn.apply(this, arguments);
  this.TEST_ENV = navigator.appVersion.match(/chromium/i) !== null;

  this.results = {}; // for debugging purpose, when there are no results sended by ajax.
};

ChromeSaturn.prototype = new Saturn();

ChromeSaturn.prototype.openNewTab = function() {
  this.tabs.nbUpdating++;
  logger.debug('in openNewTab');
  chrome.tabs.create({}, function(tab) {
    Saturn.prototype.openNewTab.call(this, tab.id);
  }.bind(this));
};

ChromeSaturn.prototype.cleanTab = function(tabId) {
  chrome.cookies.getAll({}, function(cooks) {
    var cookies=cooks;
    for (var i in cookies)
      chrome.cookies.remove({name: cookies[i].name, url: "http://"+cookies[i].domain+cookies[i].path, storeId: cookies[i].storeId});
  });
};

ChromeSaturn.prototype.openUrl = function(session, url) {
  chrome.tabs.update(session.tabId, {url: url}, function(tab) {
    // Priceminister fix when reload the same page with an #anchor set.
    if (url.match(new RegExp(tab.url+"#\\w+(=\\w+)?$")))
      chrome.tabs.update(session.tabId, {url: url});
  });
};

ChromeSaturn.prototype.closeTab = function(tabId) {
  logger.debug('in closeTab');
  Saturn.prototype.closeTab.call(this, tabId);
  chrome.tabs.remove(tabId);
};

//
ChromeSaturn.prototype.loadProductUrlsToExtract = function(doneCallback, failCallback) {
  // logger.debug("Going to get product_urls to extract...");
  return $.ajax({
    type : "GET",
    dataType: "json",
    url: this.PRODUCT_EXTRACT_URL+(this.TEST_ENV ? "?consum=false" : '')
  }).done(doneCallback).fail(failCallback);
};

// GET mapping for url's host,
// and return jqXHR object.
ChromeSaturn.prototype.loadMapping = function(merchantId, doneCallback, failCallback) {
  logger.debug("Going to get mapping for merchantId '"+merchantId+"'");
  if (typeof merchantId === 'string') {
    var toInt = parseInt(merchantId, 10);
    if (toInt)
      merchantId = toInt;
    else
      merchantId = "?url="+merchantId;
  }

  return $.ajax({
    type : "GET",
    dataType: "json",
    url: this.MAPPING_URL+merchantId
  }).done(doneCallback).fail(failCallback);
};

// Get merchant_id from url.
// Return an ajax object (see jqXHR on jQuery doc).
ChromeSaturn.prototype.getMerchantId = function(url, callback) {
  return $.ajax({
    type: "GET",
    dataType: "json",
    url: this.MAPPING_URL.slice(0,-1) + "?url=" + url
  });
};

ChromeSaturn.prototype.parseCurrentPage = function(tab) {
  this.tabs.opened[tab.id] = {};
  this.tabs.pending.unshift(tab.id);
  var prod = {url: tab.url, merchant_id: tab.url, tabId: tab.id};
  this.onProductReceived(prod);
};

//
ChromeSaturn.prototype.sendError = function(session, msg) {
  if (session.id) // Stop pushed or Local Test
    $.ajax({
      type : "PUT",
      url: this.PRODUCT_EXTRACT_UPDATE+session.id,
      contentType: 'application/json',
      data: JSON.stringify({versions: [], errorMsg: msg})
    });
  Saturn.prototype.sendError.call(this, session, msg);
};

//
ChromeSaturn.prototype.sendResult = function(session, result) {
  logger.debug("sendResult : ", result);
  if (session.id) {// Stop pushed or Local Test
    $.ajax({
      type : "PUT",
      url: this.PRODUCT_EXTRACT_UPDATE+session.id,
      contentType: 'application/json',
      data: JSON.stringify(result)
    });
  } else
    Saturn.prototype.sendResult.call(this, session, result);
};

ChromeSaturn.prototype.onTimeout = function(command) {
  return function() {
    // logger.debug("in evalAndThen, timeout for", command);
    command.callback = undefined;
    this.sendError(command.session, "something went wrong", command);
  }.bind(this);
};
ChromeSaturn.prototype.onResultReceived = function(command) {
  return function(result) {
    // logger.debug("in evalAndThen, result received, for", command);
    // Contentscript just respond to us, clear rescue.
    window.clearTimeout(command.rescueTimer);
    if (command.callback)
      command.callback(result);
  }.bind(this);
};

//
ChromeSaturn.prototype.evalAndThen = function(session, cmd, callback) {
  var command = {
    session: session,
    cmd: cmd,
    callback: callback
  };

  if (typeof callback === 'function') {
    command.rescueTimer = window.setTimeout(this.onTimeout(command), this.DELAY_RESCUE);
    command.then = this.onResultReceived(command);
  }

  chrome.tabs.sendMessage(session.tabId, cmd, command.then);
};

if ("object" == typeof module && module && "object" == typeof module.exports)
  exports = module.exports = ChromeSaturn;
else if ("function" == typeof define && define.amd)
  define("chrome_saturn", ["jquery", "saturn"],function(){return ChromeSaturn;});
else
  window.ChromeSaturn = ChromeSaturn;

})();

// Default to debug until Chrome propose tabs for each levels.
logger.level = logger.DEBUG;

var saturn = new window.ChromeSaturn();

// On contentscript ask next step (next color/size tuple).
chrome.extension.onMessage.addListener(function(msg, sender, response) {
  if (sender.id != chrome.runtime.id || ! sender.tab || ! saturn.sessions[sender.tab.id])
    return;
  if (msg == "nextStep" && saturn.sessions[sender.tab.id].then)
    saturn.sessions[sender.tab.id].then();
});

// On extension button clicked.
chrome.browserAction.onClicked.addListener(function(tab) {
  if (! saturn.TEST_ENV) {
    if (saturn.crawl) {
      logger.info("Button pressed, Saturn is paused.");
      saturn.pause();
    } else {
      logger.info("Button pressed, Saturn is resumed.");
      saturn.resume();
    }
  } else {
    logger.info("Button pressed, going to crawl current page...");
    saturn.parseCurrentPage(tab);
  }
});

chrome.tabs.onRemoved.addListener(function(tabId) {
  Saturn.prototype.closeTab.call(saturn, tabId);
});

if (! saturn.TEST_ENV)
  saturn.start();
