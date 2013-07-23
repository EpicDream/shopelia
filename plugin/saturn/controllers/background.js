
/////////////////////////////////////////////////////////////////
//                CONSTANT AND GLOBAL VARIABLE
/////////////////////////////////////////////////////////////////

TEST_ENV = false;

// if (TEST_ENV == true) {
//   SHOPELIA_DOMAIN = "http://localhost:3000"
//   MAPPING_SHOPELIA_DOMAIN = SHOPELIA_DOMAIN + "/saturn/mappings"
//   PRODUCT_EXTRACT_SHIFT_URL = SHOPELIA_DOMAIN + "/saturn/products/shift";
//   PRODUCT_EXTRACT_UPDATE = SHOPELIA_DOMAIN + "/saturn/options/create";
// } else {
  SHOPELIA_DOMAIN = "http://www.shopelia.fr"
  PRODUCT_EXTRACT_SHIFT_URL = SHOPELIA_DOMAIN + "/api/viking/products/shift";
  MAPPING_SHOPELIA_DOMAIN = SHOPELIA_DOMAIN + "/api/viking/merchants/";
  PRODUCT_EXTRACT_UPDATE = SHOPELIA_DOMAIN + "/api/viking/products/";
// }

var data = {};
var merchants = {
  "rueducommerce.fr" : "1",
  "amazon.fr" : "2",
  "fnac.com" : "3",
  "priceminister.com" : "4",
  "cdiscount.com" : "5",
  "darty.com" : "6",
  "toysrus.fr" : "7"
};

/////////////////////////////////////////////////////////////////
//                      ON CHROME EVENT
/////////////////////////////////////////////////////////////////

// On extension button clicked.
chrome.browserAction.onClicked.addListener(function(tab) {
  console.log("Button pressed, going to load Saturn..", tab.id);
  if (TEST_ENV)
    parseCurrentPage(tab);
  else
    start();
});

// On page reloaded.
chrome.tabs.onUpdated.addListener(function(tabId, info) {
  if (! data[tabId] || info.status != "complete" || info.url == "chrome://newtab/")
    return;
  loadContentScript(tabId);
});

// On contentscript ask next step (next color/size tuple).
chrome.extension.onMessage.addListener(function(msg, sender, response) {
  if (sender.id != chrome.runtime.id)
    return;
  if (msg == "nextStep")
    next_step(sender.tab.id);
});

/////////////////////////////////////////////////////////////////
//                       INIT PLUGIN
/////////////////////////////////////////////////////////////////

// Start to get product_url to extract.
function start(tabId) {
  if (tabId === undefined)
    return chrome.tabs.create({}, function(tab) {
      start(tab.id);
    });
  loadProductUrlToExtract().done(function(hash) {
    if (typeof hash != "object" || ! hash.url) {
      console.warn("Nothing to extract");
      setTimeout(function() { start(tabId) }, 30000); // 30s
      return;
    }
    var uri = new Uri(hash.url);
    console.debug("Get product_url to extract :", hash);
    loadMapping(hash.merchant_id).done(function(mapping) {
      if (! mapping.data)
        return (TEST_ENV ? null : start(tabId));
      hash.mapping = chooseMapping(uri, mapping.data);
      console.log("mapping choosen", mapping);
      hash.uri = uri;
      initTabVariables(tabId, hash);
      chrome.tabs.update(tabId, {url: hash.url});
    });
  });
};

function parseCurrentPage(tab) {
  var uri = new Uri(tab.url);
  loadMappingFromUri(uri).done(function(hash) {
    console.log("mapping-data received :", hash);
    var mapping = chooseMapping(uri, hash.data);
    console.log("mapping choosen", mapping);
    initTabVariables(tab.id, {uri: uri, url: tab.url, mapping: mapping});
    loadContentScript(tab.id);
  });
};

/////////////////////////////////////////////////////////////////
//                        LOAD INFORMATION
/////////////////////////////////////////////////////////////////

function loadProductUrlToExtract() {
  console.debug("Going to get product_url to extract...");
  return $.ajax({
    type : "GET",
    dataType: "json",
    url: PRODUCT_EXTRACT_SHIFT_URL
  }).fail(function(err) {
    console.error("When getting product_url to extract :", err);
  });
};

function chooseMapping(uri, hash) {
  var host = uri.host();
  console.log("Going to search a mapping for host", host, "between", jQuery.map(hash,function(v, k){return k;}) );
  if (hash[host])
    return hash[host];
  else
    for (var i in hash) {
      console.log(i, host.match(i));
      if (host.match(i) !== null)
        return hash[i];
    }
  return null;
};

function loadMappingFromUri(uri) {
  var host = uri.host();
  var merchant_id = null;
  if (merchants[host])
    merchant_id = merchants[host];
  else
    for (var i in merchants)
      if (host.match(i))
        merchant_id = merchants[i];
  if (! merchant_id)
    return null;
  else
    return loadMapping(merchant_id);
};

// GET mapping for url's host,
// and return jqXHR object.
function loadMapping(merchant_id) {
  console.debug("Going to get mapping for merchant_id '"+merchant_id+"'");
  return $.ajax({
    type : "GET",
    dataType: "json",
    url: MAPPING_SHOPELIA_DOMAIN+merchant_id,
  }).fail(function(err) {
    console.error("When getting mapping to extract :", err);
  });
};

function initTabVariables(tabId, hash) {
  var uri = hash.uri || new Uri(hash.url);
  data[tabId] = hash;
  data[tabId].host = uri.host();
  data[tabId].results = [];
};

function loadContentScript(tabId) {
  chrome.tabs.executeScript(tabId, {file:"lib/jquery-1.9.1.min.js"});
  chrome.tabs.executeScript(tabId, {file:"lib/underscore-min.js"});
  chrome.tabs.executeScript(tabId, {file:"controllers/contentscript.js"});
};

/////////////////////////////////////////////////////////////////
//                      CRAWLER METHODS
/////////////////////////////////////////////////////////////////

function next_step(tabId) {
  var last_action = data[tabId].last_action;
  if (! last_action)
    getColors(tabId);
  else if (last_action == "getColors")
    setNextColor(tabId);
  else if (last_action == "setColor")
    getSizes(tabId);
  else if (last_action == "getSizes")
    setNextSize(tabId);
  else if (last_action == "setSize")
    crawl(tabId);
};

function getColors(tabId) {
  console.log("Going to get colors");
  data[tabId].last_action = "getColors";
  chrome.tabs.sendMessage(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping}, function(result) {
    if (result.length > 0)
      data[tabId].colors = result;
    else
      data[tabId].colors = [null];
    setNextColor(tabId);
  });
};

function setNextColor(tabId) {
  lastColorIdx = data[tabId].lastColorIdx;
  if (lastColorIdx === undefined)
    lastColorIdx = 0;
  else
    lastColorIdx += 1;
  data[tabId].lastColorIdx = lastColorIdx;

  var color = data[tabId].colors[lastColorIdx];
  if (color === undefined) {
    data[tabId].lastColorIdx = lastColorIdx;
    return finish(tabId);
  } else if (color === null) {
    return getSizes(tabId);
  }

  data[tabId].last_action = "setColor";
  chrome.tabs.sendMessage(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping, data: color});//, function() { getSizes(tabId); });
};

function getSizes(tabId) {
  console.log("Going to get sizes");
  data[tabId].last_action = "getSizes";
  chrome.tabs.sendMessage(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping}, function(result) {
    if (result.length > 0)
      data[tabId].sizes = result;
    else
      data[tabId].sizes = [null];
    setNextSize(tabId);
  });
};

function setNextSize(tabId) {
  lastSizeIdx = data[tabId].lastSizeIdx;
  if (lastSizeIdx === undefined)
    lastSizeIdx = 0;
  else
    lastSizeIdx += 1;
  data[tabId].lastSizeIdx = lastSizeIdx;

  var size = data[tabId].sizes[lastSizeIdx];
  if (size === undefined) {
    data[tabId].lastSizeIdx = undefined;
    return setNextColor(tabId);
  } else if (size === null) {
    return crawl(tabId);
  }

  data[tabId].last_action = "setSize";
  chrome.tabs.sendMessage(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping, data: size});//, function() {crawl(tabId);});
};

function crawl(tabId) {
  console.log("Going to crawl");
  data[tabId].last_action = "crawl";
  chrome.tabs.sendMessage(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping}, function(option) {
    option.color = data[tabId].colors[data[tabId].lastColorIdx];
    option.size = data[tabId].sizes[data[tabId].lastSizeIdx];
    if (jQuery.map(option,function(v,k){return k;}).length > 2)
      data[tabId].results.push(option);
    setNextSize(tabId);
  });
};

function finish(tabId) {
  console.log("finished !", data[tabId].results);
  $.ajax({
    type : "PUT",
    url: PRODUCT_EXTRACT_UPDATE+data[tabId].id,
    contentType: "json",
    data: {versions: data[tabId].results}
  }).done(function() {
    console.debug("Options for", data[tabId].url, "sended (", data[tabId].results.length,")");
    delete data[tabId];
    if (! TEST_ENV)
      setTimeout(function() { start(tabId) }, 5000); // 5s
  }).fail(function(err) {
    console.error("Fail to send options to serverWhen getting product_url to extract for tab", tabId, ":", err);
    $e = data[tabId].results;
    console.log($e);
    if (! TEST_ENV)
      setTimeout(function() { start(tabId) }, 5000); // 5s
  });
};


/////////////////////////////////////////////////////////////////
//                            TESTS
/////////////////////////////////////////////////////////////////


function initTest(tabId) {
  var uri = new Uri("http://m.zalando.fr/polo-ralph-lauren-polo-jaune-po222d02u-202.html");
  loadMappingFromUri(uri).done(function(mapping) {
    var hash = {uri: uri, url: uri.href(), mapping: mapping.data};
    initTabVariables(tabId, hash);
    chrome.tabs.update(tabId, {url: uri.href()});
  });
  oldPRODUCT_EXTRACT_UPDATE = PRODUCT_EXTRACT_UPDATE;
  PRODUCT_EXTRACT_UPDATE = "http://localhost:0/";
};

function assertTest(tabId) {
  PRODUCT_EXTRACT_UPDATE = oldPRODUCT_EXTRACT_UPDATE;
  if (! data[tabId]) console.error("Missing data !");
  if (! data[tabId].results.length >= 10) console.error("Not enought options", data[tabId].results.length);
  var o = data[tabId].results[0];
  if (! o.name || ! o.name.match(/Polo Ralph Lauren/)) console.error("Bad name", o.name);
  if (! o.description || ! o.description.match(/100% coton/)) console.error("Bad description", o.description);
  if (! o.brand || ! o.brand.match(/Ralph Lauren/)) console.error("Bad brand", o.brand);
  if (! o.image_url || ! o.image_url.match(/http:.*\.jpe?g/)) console.error("Bad image_url", o.image_url);
  if (! o.images || ! o.images.length >= 2 || ! o.images[0].match(/http:.*\.je?pg/)) console.error("Bad images", o.images);
  if (! o.results.size || ! o.results.size.match(/../)) console.error("Bad size", o.results.size);
  if (! o.results.color || ! o.results.color.length >= 5) console.error("Bad color", o.results.color);
  if (! o.price || ! o.price.match(/\d+,\d+/)) console.error("Bad price", o.price);
  if (! o.price_strikeout) console.error("Bad price_strikeout", o.price_strikeout);
  if (! o.shipping_price || ! o.shipping_price.match(/Gratuite/)) console.error("Bad shipping_price", o.shipping_price);
  if (! o.shipping_info || ! o.shipping_info.match(/Livraison/)) console.error("Bad shipping_info", o.shipping_info);
  if (! o.availability || ! o.availability.match(/stock/)) console.error("Bad availability", o.availability);
  delete data[tabId];
};
