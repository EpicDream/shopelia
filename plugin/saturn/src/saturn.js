// Saturn
// Author : Vincent Renaudineau
// Created at : 2013-09-05

define(['logger', 'uri', './saturn_session', 'satconf'], function(logger, Uri, SaturnSession) {

"use strict";

var Saturn = function() {
  this.crawl = false;
  this.sessions = {};
  this.productsBeingProcessed = {};
  this.productQueue = [];
  this.batchQueue = [];
  this.tabs = {pending: [], opened: {}, nbUpdating: 0};
  this.mappings = {};

  this.results = {};
};

//
function buildMapping(uri, hash) {
  var host = uri.host();
  // logger.debug("Going to build a mapping for host", host, "between", jQuery.map(hash,function(v, k){return k;}) );
  var resMapping = {};
  while (host !== "") {
    if (hash[host])
      resMapping = $extend(true, {}, hash[host], resMapping);
    host = host.replace(/^[^\.]+(\.|$)/, '');
  }
  resMapping.option1 = resMapping.option1 || resMapping.colors;
  resMapping.option2 = resMapping.option2 || resMapping.sizes;
  return resMapping;
}

//
function preProcessData(data) {
  if (data.url && data.url.match(/priceminister/) !== null && data.url.match(/filter=10/) === null) {
    data.url += (data.url.match(/#/) !== null ? "&filter=10" : "#filter=10");
  }

  data.argOptions = data.options || data.argOptions || {};
  if (data.color !== undefined) data.argOptions[1] = data.color;
  if (data.size !== undefined) data.argOptions[2] = data.size;
  
  return data;
}

Saturn.prototype = {};

//
Saturn.prototype.start = function() {
  if (this.crawl)
    return;
  // init startup tabs
  for (var i = 0; i < satconf.MIN_NB_TABS; i++)
    this.openNewTab();
  this.resume();
};

//
Saturn.prototype.pause = function() {
  this.crawl = false;
  clearTimeout(this.mainCallTimeout);
};

//
Saturn.prototype.resume = function() {
  if (this.crawl)
    return;
  this.crawl = true;
  this.main();
};

//
Saturn.prototype.stop = function() {
  this.pause();
  for (var i = 0; i < this.tabs.pending.length; i++)
    this.closeTab(this.tabs.pending[i]);
  for (var tabId in this.tabs.opened)
    this.tabs.opened[tabId].toClose = true;
};

// Increase or decrease nb tabs depending product demand.
Saturn.prototype.updateNbTabs = function() {
  if (this.tabs.nbUpdating > 0)
    return;
  var pending = this.tabs.pending,
      i;
  if (this.productQueue.length === 0 && pending.length > satconf.MIN_NB_TABS) {// On ferme des tabs
    pending = pending.sort(function(i,j){return i-j;});
    var nbTabToClose = pending.length - satconf.MIN_NB_TABS;
    for (i = 0 ; i < nbTabToClose ; i++) {
      this.tabs.opened[pending[0]].toClose = true;
      this.closeTab(pending[0]);
    }
  } else { // On ouvre des tabs
    var nbMaxOpenable = satconf.MAX_NB_TABS - Object.keys(this.tabs.opened).length,
        nbWanted = satconf.MIN_NB_TABS + this.productQueue.length - pending.length,
        nbTabToOpen = nbMaxOpenable >= nbWanted ? nbWanted : nbMaxOpenable;
    if (nbTabToOpen === 0 && this.productQueue.length > 0)
      logger.warn("WARNING : Too many product to crawl ("+this.productQueue.length+") and max tabs opened ("+satconf.MAX_NB_TABS+") !");
    for (i = 0; i < nbTabToOpen ; i++)
      this.openNewTab();
  }
};

Saturn.prototype.main = function() {
  if (! this.crawl) return;

  this.loadProductUrlsToExtract(
    this.onArrayToExtractReceived.bind(this),
    this.onArrayToExtractFailed.bind(this)
  );
};

Saturn.prototype.onArrayToExtractReceived = function(array) {
  if (! array || ! (array instanceof Array)) {
    logger.err("Error when getting new products to extract : received data is undefined or is not an Array");
    this.mainCallTimeout = setTimeout(this.main.bind(this), satconf.DELAY_BETWEEN_PRODUCTS);
  } else if (array.length > 0) {
    if (logger.level <= logger.WARNING)
      logger.print("%c[%s] %d product received.", "color: blue", (new Date()).toLocaleTimeString(), array.length);
    this.onProductsReceived(array);
  } else {
    logger.print("%cNo product.", "color: blue");
    this.updateNbTabs();
  }

  this.mainCallTimeout = setTimeout(this.main.bind(this), satconf.DELAY_BETWEEN_PRODUCTS);
};

Saturn.prototype.onArrayToExtractFailed = function(err) {
  logger.error("Error when getting new products to extract :", err);
  this.mainCallTimeout = setTimeout(this.main.bind(this), satconf.DELAY_BETWEEN_PRODUCTS);
};

Saturn.prototype.onProductsReceived = function(prods) {
  logger.debug(prods.length, "products received.");
  prods = prods.unique(function(p) {return p.id;});
  for (var i = prods.length - 1; i >= 0; i--) {
    var prod = prods[i];
    if (this.productsBeingProcessed[prod.id])
      prods.splice(i,1);
    else
      this.onProductReceived(prod);
  }
  if (prods.length > 0)
    logger.info(prods.length, "products to crawl received :", prods.map(function(p) {return p.id;}));
  else
    this.updateNbTabs();
};

//
Saturn.prototype.onProductReceived = function(prod) {
  prod = preProcessData(prod);
  logger.debug("Going to process product", prod);
  var merchantId = prod.merchant_id || prod.url;
  prod.uri = new Uri(prod.url);
  prod.receivedTime = new Date();
  if (prod.mapping !== undefined) {
    this.addProductToQueue(prod);
  } else if (this.mappings[merchantId] && (prod.receivedTime - this.mappings[merchantId].date) < satconf.DELAY_BEFORE_REASK_MAPPING) {
    logger.debug("mapping from cache", merchantId, this.mappings[merchantId]);
    prod.mapping = buildMapping(prod.uri, this.mappings[merchantId].data.viking);
    this.addProductToQueue(prod);
  } else
    this.loadMapping(merchantId, function(mapping) {
      if (! mapping) {
        this.sendError({id: prod.id}, 'undefined mapping for merchant_id='+merchantId);
      } else if (! mapping.data || ! mapping.data.viking) {
        this.sendError({id: prod.id}, 'merchant_id='+merchantId+' is not supported (url='+prod.url+')');
      } else {
        this.mappings[mapping.id] = mapping;
        this.mappings[mapping.id].date = new Date();
        prod.mapping = buildMapping(prod.uri, mapping.data.viking);
        // logger.debug("mapping choosen", prod.mapping);
        this.addProductToQueue(prod);
      }
    }.bind(this), function(err) {
      if (this.mappings[merchantId]) {
        logger.warn("Error when getting mapping to extract :", err, "for", prod, '. Get the last valid one.');
        prod.mapping = buildMapping(prod.uri, this.mappings[merchantId].data.viking);
        this.addProductToQueue(prod);
      } else {
        this.sendError({id: prod.id}, "Error when getting mapping for merchant_id="+merchantId+" : "+err);
      }
    }.bind(this));
};

Saturn.prototype.addProductToQueue = function(prod) {
  if (prod.tabId === undefined) {
    this.productsBeingProcessed[prod.id] = true;
    if (prod.batch_mode)
      this.batchQueue.push(prod);
    else
      this.productQueue.push(prod);
  } else
    this.productQueue.unshift(prod);
  this.crawlProduct();
};

//
Saturn.prototype.crawlProduct = function() {

  var prod = this.productQueue[0],
      tabId;
  if (prod && prod.tabId !== undefined) {
    prod = this.productQueue.shift();
    tabId = prod.tabId;
  } else if (this.tabs.pending.length !== 0) {
    if (this.productQueue.length !== 0) {
      prod = this.productQueue.shift();
    } else if (this.batchQueue.length !== 0) {
      prod = this.batchQueue.shift();
    } else
      return;

    tabId = this.tabs.pending.shift();
    while (tabId !== undefined && this.tabs.opened[tabId].toClose === true) {
      this.closeTab(tabId);
      tabId = this.tabs.pending.shift();
    }
  } else if (prod !== undefined || this.batchQueue.length > 0) {
    return this.updateNbTabs();
  } else
    return;

  if (tabId === undefined) {
    logger.warn("in crawlProduct, tabId is undefined : updateNbTabs.");
    this.productQueue.unshift(prod); // may come from batch, but we don't care.
    this.updateNbTabs();
  } else {
    this.createSession(prod, tabId);
    this.crawlProduct();
  }
};

Saturn.prototype.createSession = function(prod, tabId) {
  var session = new SaturnSession(this, prod);
  this.sessions[tabId] = session;
  session.tabId = tabId;

  this.cleanTab(tabId);
  session.then = function() {
    session.then = function() {session.next();};
    session.start();
  };
  this.openUrl(session, prod.url);
};

Saturn.prototype.endSession = function(session) {
  delete session.then;
  delete this.productsBeingProcessed[session.id];
  var tabId = session.tabId;
  if (tabId) {
    if (satconf.env !== 'dev')
      delete this.sessions[tabId];
    if (! session.keepTabOpen)
      this.tabs.pending.push(tabId);
  }
  this.crawlProduct();
};

/////////////////////////////////////////////////////////////////
//                      ABSTRACT FUNCTIONS
/////////////////////////////////////////////////////////////////

// Virtual, must be reimplement to handle tabId is undefined and supercall with tabId.
// You must call "this.tabs.nbUpdating++;" before anything else.
Saturn.prototype.openNewTab = function(tabId) {
  if (tabId === undefined)
    throw "abstract function";  
  this.tabs.pending.push(tabId);
  this.tabs.opened[tabId] = {};
  this.tabs.nbUpdating -= 1;
  this.crawlProduct();
};

Saturn.prototype.cleanTab = function(tabId) {
};

// Virtual, must be reimplement and supercall
Saturn.prototype.closeTab = function(tabId) {
  var idx = this.tabs.pending.indexOf(tabId);
  if (idx !== -1)
    this.tabs.pending.splice(idx, 1);
  delete this.tabs.opened[tabId];
};

// Virtual, must be reimplement.
Saturn.prototype.openUrl = function(session, url) {
  throw "abstract function";
};

//
Saturn.prototype.loadProductUrlsToExtract = function(doneCallback, failCallback) {
  throw "abstract function";
};

// GET mapping for url's host,
// and return jqXHR object.
Saturn.prototype.loadMapping = function(merchantId, doneCallback, failCallback) {
  throw "abstract function";
};

// session may be a simple Object with only id to set,
// when fail to load mapping for example.
Saturn.prototype.sendError = function(session, msg) {
  window.$e = session;
  logger.err((session.tabId ? '('+session.tabId+')' : '')+(session.id ? '{'+session.id+'}' : ''), msg, "\n$e =", window.$e);
};

//
Saturn.prototype.sendResult = function(session, result) {
  var id = session.id || session.tabId;
  this.results[id] = this.results[id] || [];
  this.results[id].push(result);
};

// 
Saturn.prototype.evalAndThen = function(session, cmd, callback) {
  throw "abstract function";
};

return Saturn;

});
