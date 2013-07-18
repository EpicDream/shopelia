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

// On extension button clicked.
chrome.browserAction.onClicked.addListener(function(tab) {
  console.log("Button pressed, going to load Saturn..");
  loadMapping(tab.id, tab.url).done(function(hash) {
    startExtract(tab.id, {mapping: hash, url: tab.url});
  });
});

function getProductUrlToExtract(tabId) {
  console.debug("Going to get product_url to extract for tab", tabId);
  $.ajax({
    type : "GET",
    dataType: "json",
    url: PRODUCT_EXTRACT_SHIFT_URL
  }).done(function(hash) {
    console.debug("Get product_url to extract for tab", tabId, ":", hash);
    if (typeof hash == "object" && hash.url)
      extract_informations_for(tabId, hash);
  }).fail(function(err) {
    console.error("When getting product_url to extract for tab", tabId, ":", err);
  });
};

// GET mapping for url's host,
// and return jqXHR object.
function loadMapping(tabId, url) {
  var uri = new Uri(url);
  return $.ajax({
    type : "GET",
    // dataType: "json",
    url: MAPPING_SHOPELIA_DOMAIN,
    data: {host: uri.host()}
  }).done(function(hash) {
    console.debug("Get mapping to extract for tab", tabId, ":", hash);
  }).fail(function(err) {
    console.error("When getting mapping to extract for tab", tabId, ":", err);
  });
};

// Extract the loaded page
function startExtract(tabId, hash) {
  data[tabId] = {};
  data[tabId].url = hash.url;
  data[tabId].mapping = hash.mapping;
  data[tabId].options = [];
  loadExtractor(tabId);
};

function extract_informations_for(tabId, hash) {
  var uri = new Uri(hash.url);
  data[tabId] = {};
  data[tabId].url = hash.url;
  data[tabId].mapping = hash.mapping;
  data[tabId].options = [];
  console.debug("Open product_url to crawl at", uri);
  chrome.tabs.update(tabId, {url: hash.url});
};

chrome.tabs.onUpdated.addListener(function(tabId, info) {
  if (! data[tabId] || info.status != "complete")
    return;
  loadExtractor(tabId);
});


function loadExtractor(tabId) {
  chrome.tabs.executeScript(tabId, {file:"lib/jquery-1.9.1.min.js"});
  chrome.tabs.executeScript(tabId, {file:"lib/underscore-min.js"});
  chrome.tabs.executeScript(tabId, {file:"controllers/contentscript.js"});
};

chrome.extension.onMessage.addListener(function(msg, sender, response) {
  if (! msg == "nextStep")
    return;
  next_step(sender.tab.id);
});

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
    var color = data[tabId].colors[data[tabId].lastColorIdx];
    var size = data[tabId].sizes[data[tabId].lastSizeIdx];
    option.options = {color: color, size: size};
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
  }).fail(function(err) {
    console.error("Fail to send options to serverWhen getting product_url to extract for tab", tabId, ":", err);
    $e = data[tabId].options;
  });
};
