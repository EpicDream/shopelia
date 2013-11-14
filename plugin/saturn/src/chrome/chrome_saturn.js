// ChromeSaturn
// Author : Vincent Renaudineau
// Created at : 2013-09-05

define(["jquery", "chrome_logger", "src/saturn", 'satconf', 'core_extensions'], function($, logger, Saturn) {

"use strict";

var ChromeSaturn = function() {
  Saturn.apply(this, arguments);

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
  chrome.tabs.get(session.tabId, function(tab) {
    if (tab.url !== url)
      chrome.tabs.update(session.tabId, {url: url}, function(tab) {
        // Priceminister fix when reload the same page with an #anchor set.
        if (url.match(/#\w+(=\w+)?/))
          chrome.tabs.update(session.tabId, {url: url});
      });
    // Priceminister fix when reload the same page with an #anchor set.
    else if (url.match(/#\w+(=\w+)?/))
      chrome.tabs.update(session.tabId, {url: url});
    else
      session.next();
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
    url: satconf.PRODUCT_EXTRACT_URL+(satconf.consum ? '' : "?consum=false")
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
    url: satconf.MAPPING_URL+merchantId
  }).done(doneCallback).fail(failCallback);
};

// Get merchant_id from url.
// Return an ajax object (see jqXHR on jQuery doc).
ChromeSaturn.prototype.getMerchantId = function(url, callback) {
  return $.ajax({
    type: "GET",
    dataType: "json",
    url: satconf.MAPPING_URL.slice(0,-1) + "?url=" + url
  });
};

ChromeSaturn.prototype.parseCurrentPage = function(tab) {
  var prod = {url: tab.url, merchant_id: tab.url, tabId: tab.id, keepTabOpen: true};
  this.onProductReceived(prod);
};

//
ChromeSaturn.prototype.sendWarning = function(session, msg) {
  if (session.extensionId) {
    saturn.externalPort.postMessage({url: session.url, kind: session.kind, tabId: session.tabId, versions: [], warnMsg: msg});
  } else if (session.prod_id) // Stop pushed or Local Test
    $.ajax({
      type : "PUT",
      url: satconf.PRODUCT_EXTRACT_UPDATE+session.prod_id,
      contentType: 'application/json',
      data: JSON.stringify({versions: [], warnMsg: msg})
    });
  Saturn.prototype.sendWarning.call(this, session, msg);
};

//
ChromeSaturn.prototype.sendError = function(session, msg) {
  if (session.extensionId) {
    saturn.externalPort.postMessage({url: session.url, kind: session.kind, tabId: session.tabId, versions: [], errorMsg: msg});
  } else if (session.prod_id) // Stop pushed or Local Test
    $.ajax({
      type : "PUT",
      url: satconf.PRODUCT_EXTRACT_UPDATE+session.prod_id,
      contentType: 'application/json',
      data: JSON.stringify({versions: [], errorMsg: msg})
    }).fail(function(xhr, textStatus, errorThrown ) {
      if (textStatus === 'timeout' || xhr.status === 502) {
        $.ajax(this);
      }
    });
  Saturn.prototype.sendError.call(this, session, msg);
};

//
ChromeSaturn.prototype.sendResult = function(session, result) {
  logger.debug("sendResult : ", result);
  if (session.extensionId) {
    result.url = session.url;
    result.tabId = session.tabId;
    result.kind = session.kind;
    result.strategy = session.initialStrategy;
    saturn.externalPort.postMessage(result);
  } else if (session.prod_id) {// Stop pushed or Local Test
    $.ajax({
      tryCount: 0,
      retryLimit: 1,
      type : "PUT",
      url: satconf.PRODUCT_EXTRACT_UPDATE+session.prod_id,
      contentType: 'application/json',
      data: JSON.stringify(result)
    }).fail(function(xhr, textStatus, errorThrown) {
      if (textStatus === 'timeout' || xhr.status === 502) {
        $.ajax(this);
      } else if (xhr.status == 500 && this.tryCount < this.retryLimit) {
        this.tryCount++;
        $.ajax(this);
      }
    });
  } else
    Saturn.prototype.sendResult.call(this, session, result);
};

ChromeSaturn.prototype.onTimeout = function(command) {
  return function() {
    // logger.debug("in evalAndThen, timeout for", command);
    command.callback = undefined;
    this.sendError(command.session, "something went wrong", command);
    command.session.endSession();
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
    command.rescueTimer = window.setTimeout(this.onTimeout(command), satconf.DELAY_RESCUE);
    command.then = this.onResultReceived(command);
  }

  chrome.tabs.sendMessage(session.tabId, cmd, command.then);
};

return ChromeSaturn;

});
