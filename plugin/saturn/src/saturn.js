// Saturn
// Author : Vincent Renaudineau
// Created at : 2013-09-05

define(['logger', 'uri', './saturn_session', 'satconf', 'core_extensions'], function(logger, Uri, SaturnSession) {

"use strict";

var Saturn = function() {
  this.Session = SaturnSession; // Might be modified by subclasses.
  this.crawl = false;
  this.sessions = {};
  this.finished = {};
  this.productQueue = [];
  this.batchQueue = [];
  this.mappings = {};

  this.results = {};
};

//
function preProcessData(data) {
  data.argOptions = data.options || data.argOptions || {};
  return data;
}

//
Saturn.prototype.start = function() {
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
};

Saturn.prototype.canRestart = function () {
  return this.productQueue.length === 0 && this.batchQueue.length === 0 && Object.keys(this.sessions).length === 0;
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
  } else
    logger.print("%cNo product.", "color: blue");
  this.mainCallTimeout = setTimeout(this.main.bind(this), satconf.DELAY_BETWEEN_PRODUCTS);
};

Saturn.prototype.onArrayToExtractFailed = function(err) {
  logger.error("Error when getting new products to extract :", err);
  this.mainCallTimeout = setTimeout(this.main.bind(this), satconf.DELAY_BETWEEN_PRODUCTS);
};

Saturn.prototype.onProductsReceived = function(prods) {
  logger.debug(prods.length, "products received.");
  prods = $unique(prods);
  for (var i = prods.length - 1; i >= 0; i--)
    this.onProductReceived(prods[i]);
  if (prods.length > 0)
    logger.info(prods.length, "products to crawl received :", prods.map(function(p) {return p.id;}));
};

//
Saturn.prototype.processMapping = function(mapping, prod, merchantId) {
  if (! mapping.id) {
    this.sendWarning({prod_id: prod.id}, 'merchant_id='+merchantId+' is not supported (url='+prod.url+')');
    return false;
  } else {
    delete mapping.pages;
    this.mappings[merchantId] = mapping;
    this.mappings[merchantId].date = new Date();
  }
  return true;
};

//
Saturn.prototype.onProductReceived = function(prod) {
  prod = preProcessData(prod);
  logger.debug("Going to process product", prod);
  var merchantId = prod.merchant_id || prod.url;
  prod.uri = new Uri(prod.url);
  prod.receivedTime = new Date();
  // If mapping is already defined, add it
  if (prod.mapping !== undefined) {
    this.addProductToQueue(prod);
  // Else if cache available and not outdated
  } else if (this.mappings[merchantId] && (prod.receivedTime - this.mappings[merchantId].date) < satconf.DELAY_BEFORE_REASK_MAPPING) {
    logger.debug("mapping from cache", merchantId, this.mappings[merchantId]);
    prod.mapping = this.mappings[merchantId].currentMap;
    this.addProductToQueue(prod);
  // Else, load mapping.
  } else
    this.loadMapping(merchantId).done(this.onMappingReceived(prod, merchantId)).fail(this.onMappingFail(prod, merchantId));
};

Saturn.prototype.onMappingReceived = function(prod, merchantId) {
  return function(mapping) {
    if (! this.processMapping(mapping, prod, merchantId))
      return;
    else {
      prod.mapping = mapping.currentMap;
      this.addProductToQueue(prod);
    }
  }.bind(this);
};

Saturn.prototype.onMappingFail = function(prod, merchantId) {
  return function(err) {
    if (this.mappings[merchantId]) {
      logger.warn("Error when getting mapping to extract :", err, "for", prod, '. Get the last valid one.');
      prod.mapping = this.mappings[merchantId].currentMap;
      this.addProductToQueue(prod);
    } else
      this.sendError({prod_id: prod.id}, "Error when getting mapping for merchant_id="+merchantId+" : "+err);
  }.bind(this);
};

Saturn.prototype.addProductToQueue = function(prod) {
  if (prod.batch_mode)
    this.batchQueue.push(prod);
  else
    this.productQueue.push(prod);
  this.crawlProduct();
};

//
Saturn.prototype.crawlProduct = function() {
  if (this.productQueue[0])
    this.createSession(this.productQueue.shift());
  else if (this.batchQueue[0])
    this.createSession(this.batchQueue.shift());
};

Saturn.prototype.createSession = function(prod) {
  var session = new this.Session(this, prod);
  this.sessions[session.id] = session;
  session.start();
};

Saturn.prototype.endSession = function(session) {
  if (satconf.env === 'dev' || satconf.run_mode === 'manual')
    this.finished[session.id] = session;
  delete this.sessions[session.id];
};

/////////////////////////////////////////////////////////////////
//                      ABSTRACT FUNCTIONS
/////////////////////////////////////////////////////////////////

//
Saturn.prototype.loadProductUrlsToExtract = function(doneCallback, failCallback) {
  throw "Saturn.loadProductUrlsToExtract: abstract function";
};

// GET mapping for url's host,
// and return jqXHR object.
Saturn.prototype.loadMapping = function(merchantId, doneCallback, failCallback) {
  throw "Saturn.loadMapping: abstract function";
};

// session may be a simple Object with only id to set,
// when fail to load mapping for example.
Saturn.prototype.sendWarning = function(prod, msg) {
  window.$e = prod;
  logger.warn('/'+prod.prod_id, msg, "\n$e =", window.$e);
};

// session may be a simple Object with only id to set,
// when fail to load mapping for example.
Saturn.prototype.sendError = function(prod, msg) {
  window.$e = prod;
  logger.err('/'+prod.prod_id, msg, "\n$e =", window.$e);
};

return Saturn;

});
