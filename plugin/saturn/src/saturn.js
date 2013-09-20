// Saturn
// Author : Vincent Renaudineau
// Created at : 2013-09-05

(function() {
"use strict";

var Saturn, that = Saturn = function() {

  this.TEST_ENV = false;
  this.LOCAL_ENV = false;

  if (this.LOCAL_ENV) {
    this.SHOPELIA_DOMAIN = "http://localhost:3000";
  } else {
    this.SHOPELIA_DOMAIN = "https://www.shopelia.fr";
  }

  this.PRODUCT_EXTRACT_URL = this.SHOPELIA_DOMAIN + "/api/viking/products";
  this.MAPPING_URL = this.SHOPELIA_DOMAIN + "/api/viking/merchants/";
  this.PRODUCT_EXTRACT_UPDATE = this.SHOPELIA_DOMAIN + "/api/viking/products/";

  this.DELAY_BEFORE_START = 2000; // 2s
  this.DELAY_BETWEEN_PRODUCTS = 500; // 500ms
  this.DELAY_RESCUE = 60000; // a session automatically fail after 60s (needed when a lot of sizes for shoes for example).
  this.DELAY_BEFORE_REASK_MAPPING = this.TEST_ENV ? 30000 : 5 * 60000; // 30s en dev ou 5min en prod


  this.MAX_VERSIONS_TO_FULL_CRAWL = 100,
  this.MIN_NB_TABS = 2,
  this.MAX_NB_TABS = 15;

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
  resMapping.option1 = resMapping.colors;
  resMapping.option2 = resMapping.sizes;
  return resMapping;
};

//
function preProcessData(data) {
  if (data.url.match(/priceminister/) !== null && data.url.match(/filter=10/) === null) {
    data.url += (data.url.match(/#/) !== null ? "&filter=10" : "#filter=10");
  }

  data.argOptions = data.options || data.argOptions || {};
  if (data.color !== undefined) data.argOptions[1] = data.color;
  if (data.size !== undefined) data.argOptions[2] = data.size;
  
  return data;
};

that.prototype = {};

that.prototype.main = function() {
  if (! this.crawl) return;

  this.loadProductUrlsToExtract(false, function(array) {
    if (! array || ! (array instanceof Array)) {
      logger.err("Error when getting new products to extract : received data is undefined or is not an Array");
      this.mainCallTimeout = setTimeout(this.main.bind(this), this.DELAY_BETWEEN_PRODUCTS);
    } else if (array.length > 0) {
      this.onProductsReceived(array);
    } else {
      console.info("%cNo product.", "color: blue");
      this.updateNbTabs();
    }

    this.mainCallTimeout = setTimeout(this.main.bind(this), this.DELAY_BETWEEN_PRODUCTS);

  }.bind(this), function(err) {
    logger.error("Error when getting new products to extract :", err);
    this.mainCallTimeout = setTimeout(this.main.bind(this), this.DELAY_BETWEEN_PRODUCTS);
  }.bind(this));
};

//
that.prototype.start = function() {
  if (this.crawl)
    return;
  // init startup tabs
  for (var i = 0; i < this.MIN_NB_TABS; i++)
    this.openNewTab();
  this.resume();
};

//
that.prototype.pause = function() {
  this.crawl = false;
  clearTimeout(this.mainCallTimeout);
};

//
that.prototype.resume = function() {
  if (this.crawl)
    return;
  this.crawl = true;
  this.main();
};

//
that.prototype.stop = function() {
  this.pause();
  for (var i in this.tabs.pending)
    this.closeTab(this.tabs.pending[i]);
  for (var tabId in this.tabs.opened)
    this.tabs.opened[tabId].toClose = true;
};

// Increase or decrease nb tabs depending product demand.
that.prototype.updateNbTabs = function() {
  if (this.tabs.nbUpdating > 0)
    return;
  var pending = this.tabs.pending;
  if (this.productQueue.length == 0) {// On ferme des tabs
    var nbTabToClose = pending.length - this.MIN_NB_TABS;
    for (var i = 0 ; i < nbTabToClose ; i++) {
      this.tabs.opened[pending[i]].toClose = true;
      this.closeTab(pending[i]);      
    }
  } else { // On ouvre des tabs
    var nbMaxOpenable = this.MAX_NB_TABS - Object.keys(this.tabs.opened).length,
        nbWanted = this.productQueue.length - pending.length,
        nbTabToOpen = nbMaxOpenable >= nbWanted ? nbWanted : nbMaxOpenable;
    if (nbTabToOpen == 0)
      logger.warn("WARNING : Too many product to crawl ("+this.productQueue.length+") and max tabs opened ("+this.MAX_NB_TABS+") !");
    for (var i = 0; i < nbTabToOpen ; i++)
      this.openNewTab();
  }
};

that.prototype.onProductsReceived = function(prods) {
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
    logger.info(prods.length, "products to crawl received :", prods.map(function(p) {return p.id}));
  else
    this.updateNbTabs();
}

//
that.prototype.onProductReceived = function(prod) {
  prod = preProcessData(prod);
  logger.debug("Going to process product", prod);
  var merchantId = prod.merchant_id;
  prod.uri = new Uri(prod.url);
  prod.receivedTime = new Date();

  if (this.mappings[merchantId] && (new Date() - this.mappings[merchantId].date) < this.DELAY_BEFORE_REASK_MAPPING) {
    logger.debug("mapping from cache", merchantId, this.mappings[merchantId]);
    prod.mapping = buildMapping(prod.uri, this.mappings[merchantId].data.viking);
    this.addProductToQueue(prod);
  } else
    this.loadMapping(prod.merchant_id, function(mapping) {
      if (! mapping) {
        logger.error("`Saturn.loadMapping' : mapping is", mapping);
      } else if (! mapping.data || ! mapping.data.viking) {
        logger.warn("`Saturn.loadMapping' : merchant not supported (id="+(mapping.id ? mapping.id : prod.merchant_id)+")");
      } else {
        this.mappings[mapping.id] = mapping;
        this.mappings[mapping.id].date = new Date();
        prod.mapping = buildMapping(prod.uri, mapping.data.viking);
        // logger.debug("mapping choosen", prod.mapping);
        this.addProductToQueue(prod);
      }
    }.bind(this), function(err) {
      if (this.mappings[prod.merchant_id]) {
        logger.warn("Error when getting mapping to extract :", err, "for", prod, '. Get the last valid one.');
        prod.mapping = buildMapping(prod.uri, this.mappings[prod.merchant_id].data.viking);
        this.addProductToQueue(prod);
      } else {
        logger.error("Error when getting mapping to extract :", err, "for", prod);
      }
    }.bind(this));
};

that.prototype.addProductToQueue = function(prod) {
  this.productsBeingProcessed[prod.id] = true;
  if (prod.batch_mode)
    this.batchQueue.push(prod);
  else
    this.productQueue.push(prod);
  this.crawlProduct();
};

//
that.prototype.crawlProduct = function() {

  var prod;
  if (this.tabs.pending.length != 0) {
    if (this.productQueue.length != 0) {
      prod = this.productQueue.shift();
    } else if (this.batchQueue.length != 0) {
      prod = this.batchQueue.shift();
    } else
      return;
  } else if (this.productQueue.length != 0) {
    return this.updateNbTabs();
  } else
    return;

  var tabId = this.tabs.pending.shift();
  while (tabId !== undefined && this.tabs.opened[tabId].toClose === true) {
    this.closeTab(tabId);
    tabId = this.tabs.pending.shift();
  }
  if (tabId === undefined) {
    logger.warn("in crawlProduct, tabId is undefined : updateNbTabs.");
    this.productQueue.unshift(prod); // may come from batch, but we don't care.
    this.updateNbTabs();
  } else {
    this.createSession(prod, tabId);
    this.crawlProduct();
  }
};

that.prototype.createSession = function(prod, tabId) {
  var session = new SaturnSession(this, prod);
  this.sessions[tabId] = session;
  session.tabId = tabId;

  this.cleanTab(tabId);
  session.then = function() {
    session.then = function() {session.next()};
    session.start();
  };
  this.openUrl(session, prod.url);
};

that.prototype.endSession = function(session) {
  var tabId = session.tabId;
  if (! this.TEST_ENV)
    delete  this.sessions[session.tabId];
  delete this.productsBeingProcessed[session.id];
  this.tabs.pending.push(tabId);
  this.crawlProduct();
};

/////////////////////////////////////////////////////////////////
//                      ABSTRACT FUNCTIONS
/////////////////////////////////////////////////////////////////

// Virtual, must be reimplement to handle tabId is undefined and supercall with tabId.
// You must call "this.tabs.nbUpdating++;" before anything else.
that.prototype.openNewTab = function(tabId) {
  if (! tabId)
    throw "abstract function";  
  this.tabs.pending.push(tabId);
  this.tabs.opened[tabId] = {};
  this.tabs.nbUpdating -= 1;
  this.crawlProduct();
};

that.prototype.cleanTab = function(tabId) {
};

// Virtual, must be reimplement and supercall
that.prototype.closeTab = function(tabId) {
  var idx = this.tabs.pending.indexOf(tabId);
  if (idx !== -1)
    this.tabs.pending.splice(idx, 1);
  delete this.tabs.opened[tabId];
};

// Virtual, must be reimplement.
that.prototype.openUrl = function(session, url) {
  throw "abstract function";
};

//
that.prototype.loadProductUrlsToExtract = function(batchMode, doneCallback, failCallback) {
  throw "abstract function";
};

// GET mapping for url's host,
// and return jqXHR object.
that.prototype.loadMapping = function(merchantId, doneCallback, failCallback) {
  throw "abstract function";
};

//
that.prototype.sendError = function(session, msg) {
  window.$e = session;
  logger.err(msg, "\n$e =", window.$e);
  this.endSession(session);
};

//
that.prototype.sendResult = function(session, result) {
  var id = session.id || session.tabId;
  this.results[id] = this.results[id] || []
  this.results[id].push(result);
};

// 
that.prototype.evalAndThen = function(session, cmd, callback) {
  throw "abstract function";
};

if ("object" == typeof module && module && "object" == typeof module.exports)
  exports = module.exports = Saturn;
else if ("function" == typeof define && define.amd)
  define("saturn", ["saturn_session", "uri"], function(){return Saturn});
else
  window.Saturn = Saturn;

})();
