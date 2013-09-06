/////////////////////////////////////////////////////////////////
//                CONSTANT AND GLOBAL VARIABLE
/////////////////////////////////////////////////////////////////

TEST_ENV = true;//navigator.appVersion.match(/chromium/i) !== null;
LOCAL_ENV = false;

if (LOCAL_ENV) {
  SHOPELIA_DOMAIN = "http://localhost:3000"
} else {
  SHOPELIA_DOMAIN = "http://www.shopelia.fr"
}

PRODUCT_EXTRACT_SHIFT_URL = SHOPELIA_DOMAIN + "/api/viking/products/shift";
MAPPING_SHOPELIA_DOMAIN = SHOPELIA_DOMAIN + "/api/viking/merchants/";
PRODUCT_EXTRACT_UPDATE = SHOPELIA_DOMAIN + "/api/viking/products/";

DELAY_BEFORE_START = 5000; // 5s
DELAY_BETWEEN_PRODUCTS = 500; // 500ms
DELAY_AFTER_NO_PRODUCT = 1000; // 1s
DELAY_RESCUE = 60000; // 60s

MAX_COLORS_TO_FULL_CRAWL = 10
MAX_SIZES_TO_FULL_CRAWL = 10
MAX_VERSIONS_TO_FULL_CRAWL = 30

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
    }).fail(function(err) {
      console.error("When getting mapping to extract :", err);
      setTimeout(function() {start(tabId);}, 1000);
    });
  }).fail(function(err) {
    reask_a_product(tabId, DELAY_AFTER_NO_PRODUCT);
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
    chrome.tabs.update(tab.id, {url: hash.url}, function() {
      if (hash.url.match(new RegExp(tab.url+"#\\w+(=\\w+)?$")))
        chrome.tabs.update(tab.id, {url: hash.url});
    });
  });
};

function initTabVariables(tabId, hash) {
  var uri = hash.uri || new Uri(hash.url);
  data[tabId] = hash;
  data[tabId].host = uri.host();
  data[tabId].versions = [];
  data[tabId].options = {};
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
  if (data.color)
    try{data.color = JSON.parse(data.color);}
    catch(err){console.error(err);data.color = undefined};
  if (data.size)
    try{data.size = JSON.parse(data.size);}
    catch(err){console.error(err);data.size = undefined};
  if (! data.strategy)
    data.strategy = 'normal'
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
    url: MAPPING_SHOPELIA_DOMAIN+merchant_id
  });
};

/////////////////////////////////////////////////////////////////
//                      CRAWLER METHODS
/////////////////////////////////////////////////////////////////

function next_step(tabId) {
  var d = data[tabId];
  // Contentscript just respond to us, clear rescue.
  clearTimeout(d.rescueTimer);

  var last_action = d.last_action;
  if (! last_action) {
    return getColors(tabId);
  } else if (last_action == "setColor") {
    if (d.size)
      return setSize(tabId, d.size);
    else
      return getSizes(tabId);
  } else if (last_action == "setSize")
    return crawl(tabId);
};

function getColors(tabId) {
  data[tabId].last_action = "getColors";
  sendMsg(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping}, function(result) {
    var d = data[tabId];
    if (! result)
      return sendError(tabId, "No result return for getColors");
    else
      d.colors = result;

    if (d.colors.length == 0) {
      if (d.size)
        return setSize(tabId, d.size);
      else
        return getSizes(tabId);
    } else {
      d.options.colors = d.colors;
      if (d.strategy == 'fast') {
        return finish(tabId);
      } else // strategy == 'options' || strategy == 'full'
        return setNextColor(tabId)
    }
  });
};

function setNextColor(tabId) {
  var d = data[tabId];
  if (d.lastColorIdx === undefined)
    d.lastColorIdx = 0;
  else
    d.lastColorIdx += 1;
  var color = d.colors[d.lastColorIdx]
  if (color === undefined)
    return finish(tabId);
  setColor(tabId, color);
};

function setColor(tabId, color) {
  data[tabId].last_action = "setColor";
  data[tabId].currentColor = color;
  sendMsg(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping, data: color});
};

function getSizes(tabId) {
  data[tabId].last_action = "getSizes";
  sendMsg(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping}, function(result) {
    var d = data[tabId];
    if (! result)
      return sendError(tabId, "No result return for getSizes");
    else
      d.sizes = result;

    if (d.sizes.length > 0) {
      if (! d.currentColor) {
        d.options.sizes = d.sizes;
      } else {
        if (! d.options.sizes)
          d.options.sizes = {};
        d.options.sizes[JSON.stringify(d.currentColor)] = d.sizes;
      }
    }

    if (d.strategy == 'options')
      return setNextColor(tabId);
    else if (d.sizes.length == 0)
      return crawl(tabId);
    else {
      if (d.strategy == 'fast')
        return finish(tabId);
      else
        return setNextSize(tabId);
    }
  });
};

function setNextSize(tabId) {
  var d = data[tabId];
  if (d.lastSizeIdx === undefined)
    d.lastSizeIdx = 0;
  else
    d.lastSizeIdx += 1;
  var size = d.sizes[d.lastSizeIdx];
  if (size === undefined) {
    d.lastSizeIdx = undefined;
    return setNextColor(tabId);
  }
  setSize(tabId, size);
};

function setSize(tabId, size) {
  data[tabId].last_action = "setSize";
  data[tabId].currentSize = size;
  sendMsg(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping, data: size});
};

function crawl(tabId) {
  data[tabId].last_action = "crawl";
  sendMsg(tabId, {action: data[tabId].last_action, mapping: data[tabId].mapping}, function(option) {
    var d = data[tabId];
    if (! option)
      return sendError(tabId, "No result return for crawl");

    option.color = d.currentColor;
    option.size = d.currentSize;

    // Il faut autre chose que color ou size.
    if ((Object.keys(option).length - 2) > 0)
      d.versions.push(option);

    if (d.strategy == 'full')
      return setNextSize(tabId);
    else if (d.strategy == 'options')
      return setNextColor(tabId);
    else
      return finish(tabId);
  });
};

function finish(tabId) {
  var d = data[tabId];

  // Crée une version vide pour chaque option (sauf celle crawlée).
  var versions = [].concat(d.versions);
  if (d.strategy == 'full') {
    console.debug((new Date()).toLocaleTimeString(), "Finished full crawling !", versions);
  } else if (d.options.colors && d.options.sizes) {
    var colors = d.options.colors, 
        sizes = d.options.sizes[JSON.stringify(d.currentColor)],
        colorSizes;
    for (var i = 0, li = colors.length ; i < li ; i++) {
      var color = colors[i];
      if (d.strategy == 'options' && (colorSizes = d.options.sizes[JSON.stringify(color)]))
        sizes = colorSizes;
      for (var j = (i == 0 ? 1 : 0), lj = sizes.length ; j < lj ; j++)
        versions.push({color: color, size: sizes[j]});
    }
    console.debug((new Date()).toLocaleTimeString(), "Finished with colors and sizes !", versions);
  } else if (d.options.colors) {
    var colors = d.options.colors;
    for (var i = 1, li = colors.length ; i < li ; i++)
      versions.push({color: colors[i]});
    console.debug((new Date()).toLocaleTimeString(), "Finished with only colors !", versions);
  } else if (d.options.sizes) {
    var sizes = d.options.sizes;
    for (var i = 1, li = sizes.length ; i < li ; i++)
      versions.push({size: sizes[i]});
    console.debug((new Date()).toLocaleTimeString(), "Finished with only sizes !", versions);
  } else
    console.debug((new Date()).toLocaleTimeString(), "Finished with no color nor size !", versions);

  if (TEST_ENV && ! d.id) {
    d.id = "test"; 
  } else if (! d.id) {
    $e = d;
    return delete data[tabId];
  }

  var deferred = $.ajax({
    type : "PUT",
    url: "http://localhost:3000/api/viking/products/"+d.id,
    contentType: 'application/json',
    data: JSON.stringify({versions: versions, options_completed: versions.length == 1 || d.strategy != 'normal'})
  }).done(function() {
    console.debug("Options for", d.url, "sended (", versions.length,")");
  }).fail(function(err) {
    console.error("Fail to send options to server for tab", tabId, ":", err);
    $e = d;
    console.log("$e =", $e);
  });

  if (d.strategy == 'normal' && d.options.colors && d.options.sizes) {
    console.log("Continue to crawl options");
    d.strategy = 'options';
    setNextColor(tabId);
  } else if (d.strategy == 'normal' && d.options.colors && d.options.colors.length < MAX_COLORS_TO_FULL_CRAWL) {
    console.log("Continue to full crawl colors");
    d.strategy = 'full';
    setNextColor(tabId);
  } else if (d.strategy == 'normal' && d.options.sizes && d.options.sizes.length < MAX_SIZES_TO_FULL_CRAWL) {
    console.log("Continue to full crawl sizes");
    d.strategy = 'full';
    setNextSize(tabId);
  } else if (d.strategy == 'options' && versions.length < MAX_VERSIONS_TO_FULL_CRAWL) {
    console.log("Continue to full crawl");
    d.strategy = 'full';
    d.lastColorIdx = d.lastSizeIdx = undefined;
    d.versions = [];
    setNextColor(tabId);
  } else
    deferred.always(function() {
      delete data[tabId];
      reask_a_product(tabId, DELAY_BETWEEN_PRODUCTS);
    });

  return deferred;
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
  if (! data[tabId].versions.length >= 10) console.error("Not enought options", data[tabId].versions.length);
  var o = data[tabId].versions[0];
  if (! o.name || ! o.name.match(/Polo Ralph Lauren/)) console.error("Bad name", o.name);
  if (! o.description || ! o.description.match(/100% coton/)) console.error("Bad description", o.description);
  if (! o.brand || ! o.brand.match(/Ralph Lauren/)) console.error("Bad brand", o.brand);
  if (! o.image_url || ! o.image_url.match(/http:.*\.jpe?g/)) console.error("Bad image_url", o.image_url);
  if (! o.images || ! o.images.length >= 2 || ! o.images[0].match(/http:.*\.je?pg/)) console.error("Bad images", o.images);
  if (! o.versions.size || ! o.versions.size.match(/../)) console.error("Bad size", o.versions.size);
  if (! o.versions.color || ! o.versions.color.length >= 5) console.error("Bad color", o.versions.color);
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
