/////////////////////////////////////////////////////////////////////
//              SET CONTSTANTS AND GLOBOL VARIABLES
/////////////////////////////////////////////////////////////////////

// Where to get products and merchants.
LOCAL_ENV = false;
if (LOCAL_ENV) {
  SHOPELIA_DOMAIN = "http://localhost:3000"
} else {
  SHOPELIA_DOMAIN = "https://www.shopelia.fr"
}
PRODUCT_SHIFT_URL = SHOPELIA_DOMAIN + "/api/viking/products/failure/shift";
MAPPING_URL = SHOPELIA_DOMAIN + "/api/viking/merchants/";

var tasks = {};

// Deprecated : will be replaced by an viking api call.
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

/////////////////////////////////////////////////////////////////////
//                      ON CHROME EVENTS
/////////////////////////////////////////////////////////////////////

// On extension button clicked, start Ariane on this tab and url.
chrome.browserAction.onClicked.addListener(function(tab) {
  console.log("Button pressed, going to load Ariane on tab", tab.id);
  load(tab.id, {url: tab.url});
});

// On page reload, restart Ariane if it was started on this tab and host before.
// Clean the data for this tab if host has changed.
chrome.tabs.onUpdated.addListener(function(tabId, changeInfo) {
  if (changeInfo.status == "loading" && changeInfo.url) {
    var uri = new Uri(changeInfo.url);
    if (tasks[tabId] && uri.host() != tasks[tabId].host) {
      clean(tabId);
      console.log("Quit Ariane. Good bye !", tabId);
    }
  } else if (changeInfo.status == "complete" && tasks[tabId]) {
    load_ariane(tabId);
  }
});

// On contentscript message to background.
chrome.extension.onMessage.addListener(function(msg, sender, response) {
  if (sender.id != chrome.runtime.id) {
    console.warn("Message rejected", msg, "from sender", sender);
    return;
  }
  console.debug("Message received", msg);
  var tabId = sender.tab.id;
  if (msg == "finish" || msg.abort !== undefined) {
    send_finished_statement(tabId, msg.abort);
  } else if (msg.act == 'setMapping') {
    tasks[tabId].currentMap[msg.fieldId] = msg.value;
  }
});

// On shortcuts emited, transmit it to contentscript.
chrome.commands.onCommand.addListener(function(command) {
  chrome.tabs.getSelected(function(tab) {
    chrome.tabs.sendMessage(tab.id, command);
  });
});

// When the tab is removed, clean the data for this tab.
chrome.tabs.onRemoved.addListener(function(tabId, removeInfo) {
  clean(tabId);
});


/////////////////////////////////////////////////////////////////////
//                      LOAD PLUGIN
/////////////////////////////////////////////////////////////////////

// Start to get site to map from Shopelia.
// Like a main loop that iterates over sites.
function startWorking(tabId) {
  if (tabId === undefined) {
    // TODO : Create a new tab. Copy-Paste from Saturn.
    return;
  }
  getProductUrlToExtract().done(function(hash) {
    if (typeof hash.url != "string") {
      console.warn("No product to map.");
      return;
    }
    console.debug("Get product_url to map for tab", tabId, ":", hash);
    load(tabId, hash);
  });
};

// Get the next product url to map/extract from Shopelia.
// Return a jqXHR object. See jQuery.Deferred().
function getProductUrlToExtract() {
  console.debug("Going to get product_url to map");
  return $.ajax({
    type : "GET",
    url: PRODUCT_SHIFT_URL,
    dataType: "json"
  }).fail(function(err) {
    console.error("When getting product_url to map :", err);
  });
};

// Load Ariane for this tabId and host to map.
function load(tabId, hash) {
  initTabVariables(tabId, hash);
  if (! tasks[tabId].merchant_id)
    tasks[tabId].merchant_id = getMerchantId(tasks[tabId].uri);
  loadMapping(tasks[tabId].merchant_id).done(function(merchant) {
    tasks[tabId].merchant = merchant;
    if (merchant.data && merchant.data.viking)
      tasks[tabId].mapping = buildMapping(tabId, merchant.data.viking);
    else if (! tasks[tabId].merchant.data)
        tasks[tabId].merchant.data = {viking: {}};
    else if (! tasks[tabId].merchant.data.viking)
        tasks[tabId].merchant.data.viking = {};
    console.log("mapping chosen", tasks[tabId].mapping);
  }).always(function() {
    chrome.tabs.update(tabId, {url: tasks[tabId].url});
  });
};

// Initialize all variables for this tab and host.
function initTabVariables(tabId, hash) {
  tasks[tabId] = hash;
  tasks[tabId].uri = new Uri(hash.url);
  tasks[tabId].host = tasks[tabId].uri.host();
  tasks[tabId].mapHost = tasks[tabId].host.replace(/w{3,}\./, '');
  tasks[tabId].merchant = {data: {viking: {}}};
  tasks[tabId].merchant.data.viking[tasks[tabId].mapHost] = {};
  tasks[tabId].mapping = {};
  tasks[tabId].currentMap = {};
};

// GET mapping for merchant_id.
// Return a jqXHR object. See jQuery.Deferred().
function loadMapping(merchant_id) {
  console.debug("Going to get mapping for merchant_id '"+merchant_id+"'");
  return $.ajax({
    type : "GET",
    dataType: "json",
    url: MAPPING_URL+merchant_id,
  }).fail(function(err) {
    console.error("Fail to retrieve mapping for merchant_id "+merchant_id, err);
  });
};

// Inject libraries and contentscript into the page.
function load_ariane(tabId) {
  chrome.tabs.sendMessage(tabId, {mapping: tasks[tabId].mapping});
  console.log("Ariane loaded !");
};

// Merge the new mapping with the old, send it to shopelia, and clean data for this tab.
function send_finished_statement(tabId, reason) {
  var mapHost = tasks[tabId].mapHost;
  var previousMaps = tasks[tabId].merchant.data.viking;
  var currentMap = tasks[tabId].currentMap;
  chrome.tabs.sendMessage(tabId, {act: 'merge', host: mapHost, current: currentMap, previous: previousMaps}, function(res) {
    tasks[tabId].merchant.data.viking = res;
    $.ajax({
      type : "PUT",
      url: MAPPING_URL+tasks[tabId].merchant_id,
      contentType: 'application/json',
      data: JSON.stringify(tasks[tabId].merchant)
    });
    clean(tabId);
  });
};

// Clean data for this tab.
// All data are saved in global variable $e for debugging purpose.
function clean(tabId) {
  $e = tasks[tabId];
  delete tasks[tabId];
};

/////////////////////////////////////////////////////////////////////
//                      UTILITIES
/////////////////////////////////////////////////////////////////////

// Deprecated : Get merchant_id from uri.
// Will be replaced by an api call on Shopelia/viking.
function getMerchantId(uri) {
  var host = uri.host();
  while (host !== "") {
    if (merchants[host])
      return merchants[host];
    else
      host = host.replace(/^\w+(\.|$)/, '');
  }
  return undefined;
};

// Build a single host agnostic mapping by merging different host mapping.
function buildMapping(tabId, hash) {
  var host = tasks[tabId].mapHost;
  console.log("Going to search a mapping for host", host, "between", jQuery.map(hash,function(v, k){return k;}) );
  var resMapping = {};
  while (host !== "") {
    if (hash[host])
      resMapping = $.extend(true, {}, hash[host], resMapping);
    host = host.replace(/^\w+(\.|$)/, '');
  }
  return resMapping;
};
