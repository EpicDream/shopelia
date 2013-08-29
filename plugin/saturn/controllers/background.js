/////////////////////////////////////////////////////////////////
//                CONSTANT AND GLOBAL VARIABLE
/////////////////////////////////////////////////////////////////

TEST_ENV = navigator.appVersion.match(/chromium/i) !== null;
LOCAL_ENV = false;

if (LOCAL_ENV) {
  SHOPELIA_DOMAIN = "http://localhost:3000"
} else {
  SHOPELIA_DOMAIN = "http://www.shopelia.fr"
}

if (LOCAL_ENV && TEST_ENV) {
  MAPPING_SHOPELIA_DOMAIN = SHOPELIA_DOMAIN + "/saturn/mapping/";
  PRODUCT_EXTRACT_SHIFT_URL = SHOPELIA_DOMAIN + "/saturn/products/shift";
  PRODUCT_EXTRACT_UPDATE = SHOPELIA_DOMAIN + "/saturn/options/create";
} else {
  PRODUCT_EXTRACT_SHIFT_URL = SHOPELIA_DOMAIN + "/api/viking/products/shift";
  MAPPING_SHOPELIA_DOMAIN = SHOPELIA_DOMAIN + "/api/viking/merchants/";
  PRODUCT_EXTRACT_UPDATE = SHOPELIA_DOMAIN + "/api/viking/products/";
}

DELAY_BEFORE_START = 5000; // 5s
DELAY_BETWEEN_PRODUCTS = 500; // 500ms
DELAY_AFTER_NO_PRODUCT = 1000; // 1s
DELAY_RESCUE = 60000; // 60s

var data = {},
    batchTabs = {};
var reask = ! TEST_ENV;
var merchants = {
  "rueducommerce.fr" : "1",
  "amazon.fr" : "2",
  "fnac.com" : "3",
  "priceminister.com" : "4",
  "cdiscount.com" : "5",
  "darty.com" : "6",
  "toysrus.fr" : "7",
  "conforama.fr" : "8",
  "eveiletjeux.com" : "9",
  "sephora.fr" : "10",
  "thebodyshop.fr" : "11",
  "zalando.fr" : "12"
};

/////////////////////////////////////////////////////////////////
//                      ON CHROME EVENT
/////////////////////////////////////////////////////////////////

// On extension button clicked.
chrome.browserAction.onClicked.addListener(function(tab) {
  console.log("Button pressed, going to load Saturn..");
  if (! TEST_ENV) {
    reask = ! reask;
    if (reask)
      start(tab.id);
  } else {
    if (isParsable(tab.url))
      parseCurrentPage(tab);
    else
      start(tab.id);
  }
});

// On contentscript ask next step (next color/size tuple).
chrome.extension.onMessage.addListener(function(msg, sender, response) {
  if (sender.id != chrome.runtime.id || ! sender.tab || ! data[sender.tab.id])
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
  loadProductUrlToExtract(tabId).done(function(hash) {
    hash = preProcessData(hash);
    var uri = new Uri(hash.url);
    console.debug((new Date()).toLocaleTimeString(), "Get product_url to extract :", hash, "on tab_id :", tabId);
    loadMapping(hash.merchant_id).done(function(mapping) {
      if (mapping.data && mapping.data.viking)
        hash.mapping = buildMapping(uri, mapping.data.viking);
      console.log("mapping choosen", hash.mapping);
      hash.uri = uri;
      initTabVariables(tabId, hash);
      if (hash.mapping)
        chrome.tabs.update(tabId, {url: hash.url});
      else
        finish(tabId);
    });
  });
};

function parseCurrentPage(tab) {
  console.debug((new Date()).toLocaleTimeString(), "Get product_url to extract :", {url: tab.url}, "on tab_id :", tab.id);
  var hash = preProcessData({url: tab.url});
  hash.uri = new Uri(hash.url);
  loadMappingFromUri(hash.uri).done(function(maphash) {
    console.log("mapping-data received :", maphash);
    hash.mapping = buildMapping(hash.uri, maphash.data.viking);
    console.log("mapping choosen", hash.mapping);
    initTabVariables(tab.id, hash);
    chrome.tabs.update(tab.id, {url: hash.url});
  });
};

function initTabVariables(tabId, hash) {
  var uri = hash.uri || new Uri(hash.url);
  data[tabId] = hash;
  data[tabId].host = uri.host();
  data[tabId].results = [];
  // Remove all previous cookies
  chrome.cookies.getAll({},function(cooks){cookies=cooks;for (var i in cookies) {chrome.cookies.remove({name: cookies[i].name, url: "http://"+cookies[i].domain+cookies[i].path, storeId: cookies[i].storeId})}})
};

/////////////////////////////////////////////////////////////////
//                         UTILITIES
/////////////////////////////////////////////////////////////////

function reask_a_product(tabId, delay) {
  if (! reask)
    return;
  delay = delay || 3000;
  setTimeout(function() { start(tabId) }, delay);
};

function buildMapping(uri, hash) {
  var host = uri.host();
  console.log("Going to build a mapping for host", host, "between", jQuery.map(hash,function(v, k){return k;}) );
  var resMapping = {};
  while (host !== "") {
    if (hash[host])
      resMapping = $.extend(true, {}, hash[host], resMapping);
    host = host.replace(/^[^\.]+(\.|$)/, '');
  }
  return resMapping;
};

function isParsable(url) {
  for (var key in merchants)
    if (url.match(key) !== null)
      return true;
  return false;
};

function preProcessData(data) {
  if (data.url.match(/priceminister/) !== null && data.url.match(/filter=10/) === null) {
    data.url += (data.url.match(/#/) !== null ? "&filter=10" : "#filter=10");
  }
  return data;
};

// Send the message with chrome.tabs.sendMessage
// plus add a rescue system if something went wrong and no response is sent.
function sendMsg(tabId, msg, callback) {
  // Message is going to be sent to contentscript, active rescue.
  data[tabId].rescueTimer = setTimeout(rescueFunction(tabId), DELAY_RESCUE);
  chrome.tabs.sendMessage(tabId, msg, function(result) {
    // Contentscript just respond to us, clear rescue.
    clearTimeout(data[tabId].rescueTimer);
    if (callback) callback(result);
  });
};

// If something went wrong, respond with an error message,
// clear data, and reask a product to crawl.
function rescueFunction(tabId) {
  return function() {
    sendError(tabId, "something went wrong");
  };
};

/////////////////////////////////////////////////////////////////
//                        LOAD INFORMATION
/////////////////////////////////////////////////////////////////

function loadProductUrlToExtract(tabId) {
  console.debug("Going to get product_url to extract...");
  return $.ajax({
    type : "GET",
    dataType: "json",
    url: PRODUCT_EXTRACT_SHIFT_URL+((batchTabs[tabId] === true) ? "?batch=true" : "")
  }).fail(function(err) {
    // console.error("When getting product_url to extract :", err);
    reask_a_product(tabId, DELAY_AFTER_NO_PRODUCT);
  });
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
  console.log("Going to get mapping for merchant_id '"+merchant_id+"'");
  return $.ajax({
    type : "GET",
    dataType: "json",
    url: MAPPING_SHOPELIA_DOMAIN+merchant_id,
  }).fail(function(err) {
    console.error("When getting mapping to extract :", err);
  });
};

/////////////////////////////////////////////////////////////////
//                      CRAWLER METHODS
/////////////////////////////////////////////////////////////////

function next_step(tabId) {
  // Contentscript just respond to us, clear rescue.
  clearTimeout(data[tabId].rescueTimer);

  var last_action = data[tabId].last_action;
  if (! last_action)
    getColors(tabId);
  else if (last_action == "setColor")
    getSizes(tabId);
  else if (last_action == "setSize")
    crawl(tabId);
};

function getColors(tabId) {
  data[tabId].last_action = "getColors";
  sendMsg(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping}, function(result) {
    if (! result)
      return sendError(tabId, "No result return for getColors");

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
  sendMsg(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping, data: color});
};

function getSizes(tabId) {
  data[tabId].last_action = "getSizes";
  sendMsg(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping}, function(result) {
    if (! result)
      return sendError(tabId, "No result return for getSizes");

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
  sendMsg(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping, data: size});
};

function crawl(tabId) {
  data[tabId].last_action = "crawl";
  sendMsg(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping}, function(option) {
    if (! option)
      return sendError(tabId, "No result return for crawl");

    option.color = data[tabId].colors[data[tabId].lastColorIdx];
    option.size = data[tabId].sizes[data[tabId].lastSizeIdx];
    // Il faut autre chose que color ou size.
    if ((_.size(option) - 2) > 0)
      data[tabId].results.push(option);
    setNextSize(tabId);
  });
};

function finish(tabId) {
  console.debug((new Date()).toLocaleTimeString(), "Finished !", data[tabId].results);
  if (! data[tabId] || ! data[tabId].id) // Stop pushed or Local Test
    return delete data[tabId];

  $.ajax({
    type : "PUT",
    url: PRODUCT_EXTRACT_UPDATE+data[tabId].id,
    contentType: 'application/json',
    data: JSON.stringify({versions: data[tabId].results})
  }).done(function() {
    console.debug("Options for", data[tabId].url, "sended (", data[tabId].results.length,")");
    delete data[tabId];
    reask_a_product(tabId, DELAY_BETWEEN_PRODUCTS);
  }).fail(function(err) {
    console.error("Fail to send options to server for tab", tabId, ":", err);
    $e = data[tabId];
    console.log("$e =", $e);
    delete data[tabId];
    reask_a_product(tabId, DELAY_BETWEEN_PRODUCTS);
  });
};

function sendError(tabId, msg) {
  if (data[tabId] && data[tabId].id) // Stop pushed or Local Test
    $.ajax({
      type : "PUT",
      url: PRODUCT_EXTRACT_UPDATE+data[tabId].id,
      contentType: 'application/json',
      data: JSON.stringify({versions: []}) //, errorMsg: msg
    });
  $e = data[tabId];
  console.log((new Date()).toLocaleTimeString(), msg, "\n$e =", $e);
  delete data[tabId];
  reask_a_product(tabId, DELAY_BETWEEN_PRODUCTS);
};

/////////////////////////////////////////////////////////////////
//                            TESTS
/////////////////////////////////////////////////////////////////


function initTest(tabId) {
  var uri = new Uri("http://m.zalando.fr/polo-ralph-lauren-polo-jaune-po222d02u-202.html");
  loadMappingFromUri(uri).done(function(mapping) {
    var hash = {uri: uri, url: uri.href(), mapping: mapping.data.viking};
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
  if (! o.price_shipping || ! o.price_shipping.match(/Gratuite/)) console.error("Bad price_shipping", o.price_shipping);
  if (! o.shipping_info || ! o.shipping_info.match(/Livraison/)) console.error("Bad shipping_info", o.shipping_info);
  if (! o.availability || ! o.availability.match(/stock/)) console.error("Bad availability", o.availability);
  delete data[tabId];
};

if (! TEST_ENV) {
  chrome.tabs.create({}, function(tab) {
    batchTabs[tab.id] = false;
    reask_a_product(tab.id, DELAY_BEFORE_START);
  });
  chrome.tabs.create({}, function(tab) {
    batchTabs[tab.id] = true;
    reask_a_product(tab.id, DELAY_BEFORE_START);
  });
}
