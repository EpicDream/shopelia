
/////////////////////////////////////////////////////////////////
//                CONSTANT AND GLOBAL VARIABLE
/////////////////////////////////////////////////////////////////

TEST_ENV = true

if (TEST_ENV == true) {
  SHOPELIA_DOMAIN = "http://localhost:3000"
  MAPPING_SHOPELIA_DOMAIN = SHOPELIA_DOMAIN + "/saturn/mappings"
  PRODUCT_EXTRACT_SHIFT_URL = SHOPELIA_DOMAIN + "/saturn/products/shift";
  PRODUCT_EXTRACT_UPDATE = SHOPELIA_DOMAIN + "/saturn/options/create";
} else {
  SHOPELIA_DOMAIN = "http://www.shopelia.fr"
  MAPPING_SHOPELIA_DOMAIN = SHOPELIA_DOMAIN + "/api/viking/mappings"
  PRODUCT_EXTRACT_SHIFT_URL = SHOPELIA_DOMAIN + "/api/viking/products/shift";
  PRODUCT_EXTRACT_UPDATE = SHOPELIA_DOMAIN + "/api/viking/";
}

var data = {};

/////////////////////////////////////////////////////////////////
//                      ON CHROME EVENT
/////////////////////////////////////////////////////////////////

// On extension button clicked.
chrome.browserAction.onClicked.addListener(function(tab) {
  console.log("Button pressed, going to load Saturn..");
  start();
  // parseCurrentPage(tab);
});

// On page reloaded.
chrome.tabs.onUpdated.addListener(function(tabId, info) {
  if (! data[tabId] || info.status != "complete")
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
    console.debug("Get product_url to extract :", hash);
    loadMapping(hash.url).done(function(mapping) {
      hash.mapping = mapping;
      initTabVariables(tabId, hash);
      chrome.tabs.update(tabId, {url: hash.url});
    });
  });
};

function parseCurrentPage(tab) {
  loadMapping(tab.url).done(function(mapping) {
    initTabVariables(tab.id, {url: tab.url, mapping: mapping});
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
    console.error("When getting product_url to extract for tab", tabId, ":", err);
  });
};

// GET mapping for url's host,
// and return jqXHR object.
function loadMapping(url) {
  var uri = new Uri(url);
  console.debug("Going to get mapping for host '"+uri.host()+"'");
  return $.ajax({
    type : "GET",
    // dataType: "json",
    url: MAPPING_SHOPELIA_DOMAIN,
    data: {host: uri.host()}
  }).fail(function(err) {
    console.error("When getting mapping to extract :", err);
  });
};

function initTabVariables(tabId, hash) {
  var uri = new Uri(hash.url);
  data[tabId] = {};
  data[tabId].url = hash.url;
  data[tabId].host = uri.host();
  data[tabId].mapping = hash.mapping;
  data[tabId].options = [];
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
    // option.options = {color: color, size: size};
    data[tabId].options.push(option);
    setNextSize(tabId);
  });
};

function finish(tabId) {
  console.log("finished !", data[tabId].options);
  $.ajax({
    type : "PUT",
    url: PRODUCT_EXTRACT_UPDATE,
    // contentType: "json",
    data: {url: data[tabId].url, options: data[tabId].options}
  }).done(function() {
    console.debug("Options for", data[tabId].url, "sended (", data[tabId].options.length,")");
    delete data[tabId];
    start(tabId);
  }).fail(function(err) {
    console.error("Fail to send options to serverWhen getting product_url to extract for tab", tabId, ":", err);
    $e = data[tabId].options;
    console.log($e);
    start(tabId);
  });
};


/////////////////////////////////////////////////////////////////
//                            TESTS
/////////////////////////////////////////////////////////////////


function initTest(tabId) {
  var url = "http://m.zalando.fr/polo-ralph-lauren-polo-jaune-po222d02u-202.html";
  loadMapping(url).done(function(mapping) {
    var hash = {url: url, mapping: mapping};
    initTabVariables(tabId, hash);
    chrome.tabs.update(tabId, {url: hash.url});
  });
  oldPRODUCT_EXTRACT_UPDATE = PRODUCT_EXTRACT_UPDATE;
  PRODUCT_EXTRACT_UPDATE = "http://localhost:0/";
};

function assertTest(tabId) {
  PRODUCT_EXTRACT_UPDATE = oldPRODUCT_EXTRACT_UPDATE;
  if (! data[tabId]) console.error("Missing data !");
  if (! data[tabId].options.length >= 10) console.error("Not enought options", data[tabId].options.length);
  var o = data[tabId].options[0];
  if (! o.name || ! o.name.match(/Polo Ralph Lauren/)) console.error("Bad name", o.name);
  if (! o.description || ! o.description.match(/100% coton/)) console.error("Bad description", o.description);
  if (! o.brand || ! o.brand.match(/Ralph Lauren/)) console.error("Bad brand", o.brand);
  if (! o.image_url || ! o.image_url.match(/http:.*\.jpe?g/)) console.error("Bad image_url", o.image_url);
  if (! o.images || ! o.images.length >= 2 || ! o.images[0].match(/http:.*\.je?pg/)) console.error("Bad images", o.images);
  if (! o.options.size || ! o.options.size.match(/../)) console.error("Bad size", o.options.size);
  if (! o.options.color || ! o.options.color.length >= 5) console.error("Bad color", o.options.color);
  if (! o.price || ! o.price.match(/\d+,\d+/)) console.error("Bad price", o.price);
  if (! o.price_strikeout) console.error("Bad price_strikeout", o.price_strikeout);
  if (! o.shipping_price || ! o.shipping_price.match(/Gratuite/)) console.error("Bad shipping_price", o.shipping_price);
  if (! o.shipping_info || ! o.shipping_info.match(/Livraison/)) console.error("Bad shipping_info", o.shipping_info);
  if (! o.availability || ! o.availability.match(/stock/)) console.error("Bad availability", o.availability);
  delete data[tabId];
};
