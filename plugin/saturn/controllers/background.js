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

PRODUCT_EXTRACT_SHIFT_URL = SHOPELIA_DOMAIN + "/api/viking/products/shift";
MAPPING_SHOPELIA_DOMAIN = SHOPELIA_DOMAIN + "/api/viking/merchants/";
PRODUCT_EXTRACT_UPDATE = SHOPELIA_DOMAIN + "/api/viking/products/";

DELAY_BEFORE_START = 5000; // 5s
DELAY_BETWEEN_PRODUCTS = 500; // 500ms
DELAY_AFTER_NO_PRODUCT = 1000; // 1s
DELAY_RESCUE = 60000; // 60s

MAX_VERSIONS_TO_FULL_CRAWL = 100;

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
    nextStep(sender.tab.id);
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
    if (! hash)
      return reaskProduct(tabId, DELAY_AFTER_NO_PRODUCT);
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
      console.error("When getting mapping for crawling :", err);
      setTimeout(function() {start(tabId);}, 1000);
    });
  }).fail(function(err) {
    console.error("When getting product to crawl :", err);
    reaskProduct(tabId, DELAY_AFTER_NO_PRODUCT);
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
  var d = data[tabId] = hash;
  d.host = d.uri.host();
  d.versions = [];
  d.argOptions = d.options || [];
  d.options = [];
  d.nbOptions = 0;
  d.currentOptions = [];
  d.currentOptionsIdx = [];
  // Remove all previous cookies
  chrome.cookies.getAll({},function(cooks){cookies=cooks;for (var i in cookies) {chrome.cookies.remove({name: cookies[i].name, url: "http://"+cookies[i].domain+cookies[i].path, storeId: cookies[i].storeId})}})
};

/////////////////////////////////////////////////////////////////
//                         UTILITIES
/////////////////////////////////////////////////////////////////

function reaskProduct(tabId, delay) {
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
  resMapping.option1 = resMapping.colors;
  resMapping.option2 = resMapping.sizes;
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
    data.strategy = 'normal';
  data.options = data.options || [];
  if (data.color) data.options[0] = data.color;
  if (data.size) data.options[1] = data.size;
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
  var merchantId = null;
  if (merchants[host])
    merchantId = merchants[host];
  else
    for (var i in merchants)
      if (host.match(i))
        merchantId = merchants[i];
  if (! merchantId)
    return null;
  else
    return loadMapping(merchantId);
};

// GET mapping for url's host,
// and return jqXHR object.
function loadMapping(merchantId) {
  console.log("Going to get mapping for merchantId '"+merchantId+"'");
  return $.ajax({
    type : "GET",
    dataType: "json",
    url: MAPPING_SHOPELIA_DOMAIN+merchantId
  });
};

/////////////////////////////////////////////////////////////////
//                      CRAWLER METHODS
/////////////////////////////////////////////////////////////////

// Called after the first page load,
// and when page reload/ask after an option is set.
function nextStep(tabId) {
  var d = data[tabId];
  // Contentscript just respond to us, clear rescue.
  clearTimeout(d.rescueTimer);

  if (! d.currentAction)
    return getOptions(tabId, 0);

  if (d.argOptions[d.lastLevel+1])
    return setOption(tabId, d.lastLevel+1, d.argOptions[d.lastLevel+1]);
  else
    return getOptions(tabId, d.lastLevel+1);
};

// Get (if options is undefined) or set (if options is set)
// available options for level and optionsIdx.
// optionsIdx is default to currentOptionsIdx.
function optionsTreeFor(tabId, level, optionsIdx, options) {
  var d = data[tabId];
  optionsIdx = optionsIdx || d.currentOptionsIdx.slice(0, level).filter(function(e){return e!==undefined && e!==null});
  var tree = d.options;
  var idx = level;
  for (var i = 0, l = optionsIdx.length ; i < l ; i++) {
    if (! tree[idx] && options)
      tree[idx] = [];
    else if (! tree[idx])
      return [];
    tree = tree[idx];
    idx = optionsIdx[i];
  }
  return options ? tree[idx] = options : tree[idx] || [];
};

// Ask the contentscript to get options for this level.
function getOptions(tabId, level) {
  if (! data[tabId].mapping["option"+(level+1)])
    return crawl(tabId);

  data[tabId].currentAction = "getOptions";
  sendMsg(tabId, {action: data[tabId].currentAction, mapping: data[tabId].mapping, level: level}, function(options) {
    var d = data[tabId];
    if (! options)
      return sendError(tabId, "No options return for getOptions(level="+level+")");

    optionsTreeFor(tabId, level, undefined, options);
    if (options.length > 0)
      d.nbOptions += 1;

    if (d.strategy == 'options') {
      if (d.options.length > level+1)
        return setNextOption(tabId, level);
      else
        return setNextOption(tabId, level-1, true);
    } else if (options.length == 0) {
      if (d.argOptions[level+1])
        return setOption(tabId, level+1, d.argOptions[level+1]);
      else
        return getOptions(tabId, level+1);
    } else if (d.strategy == 'fast') {
      return finish(tabId);
    } else
      return setNextOption(tabId, level);
  });
};

// Compute the next option to set for this level et set it via setOption().
function setNextOption(tabId, level, back) {
  if (level < 0)
    return finish(tabId);

  var d = data[tabId];
  if (d.currentOptionsIdx[level] === undefined)
    d.currentOptionsIdx[level] = 0;
  else
    d.currentOptionsIdx[level] += 1;

  var options = optionsTreeFor(tabId, level);
  if (options.length == 0) {
    d.currentOptionsIdx[level] = undefined;
    if (! back && level < d.options.length-1)
      return setNextOption(tabId, level+1);
    else
      return setNextOption(tabId, level-1, true);
  }

  var option = options[ d.currentOptionsIdx[level] ];
  if (option !== undefined) {
    setOption(tabId, level, option);
  } else {
    d.currentOptionsIdx[level] = undefined;
    setNextOption(tabId, level-1, true);
  }
};

// Ask the contentscript to select the option.
function setOption(tabId, level, option) {
  var d = data[tabId];
  d.currentAction = "setOption";
  d.lastLevel = level;
  d.currentOptions[level] = option;
  sendMsg(tabId, {action: d.currentAction, mapping: d.mapping, level: level, option: option});
};

// Ask the contentscript to crawl the product (for the current options if any).
function crawl(tabId) {
  data[tabId].currentAction = "crawl";
  sendMsg(tabId, {action: data[tabId].currentAction, mapping: data[tabId].mapping}, function(version) {
    var d = data[tabId];
    if (! version)
      return sendError(tabId, "No result return for crawl");

    if (Object.keys(version).length > 0) {
      for (var lvl = 0, l = d.currentOptions.length ; lvl < l ; lvl++)
        if (d.currentOptions[lvl])
          version["option"+(lvl+1)] = d.currentOptions[lvl];
      d.versions.push(version);
    }

    if (d.strategy == 'full' && d.lastLevel !== undefined)
      return setNextOption(tabId, d.lastLevel, true);
    else
      return finish(tabId);
  });
};

// Fonction récursive de creation de version.
// Crée autant de version qu'il y a de combinaison d'options.
// Si strategy is set to 'normal' alors il crée la matrice des options possible à partir des seules options disponibles.
// versions is the final Array.
// hash is the pattern for versions.
// level must be set to 0.
// currentIdx must be set to [].
function createOptionedVersions(tabId, versions, hash, level, currentIdx) {
  var d = data[tabId];
  var options = optionsTreeFor(tabId, level, currentIdx, undefined) || [];
  // Si pas d'options, on ajoute la version actuelle et on retourne.
  if (options.length == 0 && level < d.options.length) {
    createOptionedVersions(tabId, versions, hash, level+1, currentIdx);
  } else if (options.length == 0) {
    versions.push($.extend({},hash));
  } else {
    for (var i = 0, l = options.length ; i < l ; i++) {
      hash["option"+(level+1)] = options[i];
      createOptionedVersions(tabId, versions, hash, level+1, currentIdx.concat([d.strategy == 'normal' ? 0 : i]));
    }
    delete hash["option"+(level+1)];
  }
  return versions;
};

// When current task is done, finish() is called.
function finish(tabId) {
  var d = data[tabId];

  // Crée une version vide pour chaque option (sauf celle crawlée) si on est pas en stratégie 'full'.
  var versions = d.strategy == 'full' ? d.versions : d.versions.concat(createOptionedVersions(tabId, [], {}, 0, []).slice(1));
  console.debug((new Date()).toLocaleTimeString(), "Finished", d.strategy, "crawling !", versions);

  if (TEST_ENV && ! d.id) {
    d.id = "test"; 
  } else if (! d.id) {
    $e = d;
    return delete data[tabId];
  }

  // Send crawled versions with ajax.
  var deferred = $.ajax({
    type : "PUT",
    url: PRODUCT_EXTRACT_UPDATE+d.id,
    contentType: 'application/json',
    data: JSON.stringify({versions: versions, options_completed: versions.length == 1 || d.strategy != 'normal'})
  }).done(function() {
    console.debug("Options for", d.url, "sended (", versions.length,")");
  }).fail(function(err) {
    console.error("Fail to send options to server for tab", tabId, ":", err);
    $e = d;
    console.log("$e =", $e);
  });

  // Look if we can continue to crawl more informations.
  if (d.strategy == 'normal' && d.nbOptions > 1) {
    console.log("Continue to crawl only options");
    d.strategy = 'options';
    setNextOption(tabId, d.options.length - 2, true);
  } else if ((d.strategy == 'normal' && d.nbOptions == 1) ||
      (d.strategy == 'options' && versions.length < MAX_VERSIONS_TO_FULL_CRAWL)) {
    console.log("Continue with full crawling");
    d.strategy = 'full';
    d.currentOptionsIdx = [];
    d.versions = [];
    setNextOption(tabId, 0);
  } else
    deferred.always(function() {
      delete data[tabId];
      reaskProduct(tabId, DELAY_BETWEEN_PRODUCTS);
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
  reaskProduct(tabId, DELAY_BETWEEN_PRODUCTS);
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
    reaskProduct(tab.id, DELAY_BEFORE_START);
  });
  chrome.tabs.create({}, function(tab) {
    batchTabs[tab.id] = true;
    reaskProduct(tab.id, DELAY_BEFORE_START);
  });
}
