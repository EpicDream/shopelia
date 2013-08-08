/////////////////////////////////////////////////////////////////////
//              SET CONTSTANTS AND GLOBOL VARIABLES
/////////////////////////////////////////////////////////////////////

LOCAL_ENV = false;
if (LOCAL_ENV) {
  SHOPELIA_DOMAIN = "http://localhost:3000"
} else {
  SHOPELIA_DOMAIN = "https://www.shopelia.fr"
}
PRODUCT_SHIFT_URL = SHOPELIA_DOMAIN + "/api/viking/products/failure/shift";
MAPPING_URL = SHOPELIA_DOMAIN + "/api/viking/merchants/";

var tasks = {};

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
  "zalando.fr" : "12",
  "jcrew.com" : "13",
  "overstock.com" : "14",
  "effiliation.com" : "15"
};

/////////////////////////////////////////////////////////////////////
//                      ON CHROME EVENTS
/////////////////////////////////////////////////////////////////////

// On extension button clicked, start Ariane on this page.
chrome.browserAction.onClicked.addListener(function(tab) {
  console.log("Button pressed, going to load Ariane on tab", tab.id);
  load(tab.id, {url: tab.url});
});

// On page reload, restart Ariane if it was started before.
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

// On contentscript message.
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
  } else if (msg.act == 'setSearchResult') {
    tasks[tabId].searchResult = msg.value;
  }
});

// On shortcuts emited, transmit it to contentscript.
chrome.commands.onCommand.addListener(function(command) {
  chrome.tabs.getSelected(function(tab) {
    chrome.tabs.sendMessage(tab.id, command);
  });
});

//
chrome.tabs.onRemoved.addListener(function(tabId, removeInfo) {
  clean(tabId);
});


/////////////////////////////////////////////////////////////////////
//                      LOAD PLUGIN
/////////////////////////////////////////////////////////////////////

//
function start(tabId) {
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

//
function initTabVariables(tabId, hash) {
  tasks[tabId] = hash;
  tasks[tabId].uri = new Uri(hash.url);
  tasks[tabId].host = tasks[tabId].uri.host();
  tasks[tabId].mapHost = tasks[tabId].host.replace(/w{3,}\./, '');
  tasks[tabId].fullMapping = {};
  tasks[tabId].fullMapping[tasks[tabId].mapHost] = {};
  tasks[tabId].mapping = {};
  tasks[tabId].currentMap = {};
  tasks[tabId].searchResult = {};
};

// Get from Shopelia the next product url to map/extract.
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

//
function load(tabId, hash) {
  initTabVariables(tabId, hash);
  if (! tasks[tabId].merchant_id)
    tasks[tabId].merchant_id = getMerchantId(tasks[tabId].uri);
  loadMapping(tasks[tabId].merchant_id).done(function(mapping) {
    if (mapping.data) {
      tasks[tabId].fullMapping = mapping.data;
      tasks[tabId].mapping = buildMapping(tabId, mapping.data);
    }
    console.log("mapping chosen", tasks[tabId].mapping);
  }).always(function() {
    chrome.tabs.update(tabId, {url: tasks[tabId].url});
  });
};

//
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

// GET mapping for merchant_id,
// and return jqXHR object.
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

// Send new mapping to shopelia
function send_finished_statement(tabId, reason) {
  mergeMappings(tabId);
  $.ajax({
    type : "PUT",
    url: MAPPING_URL+tasks[tabId].merchant_id,
    contentType: 'application/json',
    data: JSON.stringify({
      verb: reason ? 'bounce' : 'success',
      data: tasks[tabId].fullMapping,
      reason: reason
    })
  });
  clean(tabId);
};

// Clean variables
function clean(tabId) {
  $e = tasks[tabId];
  delete tasks[tabId];
};

/////////////////////////////////////////////////////////////////////
//                      UTILITIES
/////////////////////////////////////////////////////////////////////

//
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

//
function mergeMappings(tabId) {
  // GOING TO MERGE NEW MAPPING WITH OLD ONES
  // create new host rule if it did not exist.
  if (! tasks[tabId].fullMapping[tasks[tabId].mapHost])
    tasks[tabId].fullMapping[tasks[tabId].mapHost] = {};

  // for each field key
  var mapping = tasks[tabId].fullMapping[tasks[tabId].mapHost];
  var currentMap = tasks[tabId].currentMap;
  for (var key in jQuery.extend({}, mapping, currentMap)) {
    // if no new map, continue
    if (! currentMap[key])
      continue;
    // if it did not exist, just create it and continue.
    if (! mapping[key]) {
      mapping[key] = currentMap[key];
      continue;
    }
    // if old version, update it.
    if (! mapping[key].path instanceof Array)
      mapping[key] = {path: [mapping[key].path], context: [mapping[key].context]};
    // if some elements where already found, unshift new rafinement.
    if (tasks[tabId].searchResult[key]) {
      mapping[key].path.splice(0,0,currentMap[key].path);
      mapping[key].context.splice(0,0,currentMap[key].context);
    // else, if nothing matched, push it behind.
    } else {
      mapping[key].path.push(currentMap[key].path);
      mapping[key].context.push(currentMap[key].context);
    }
  }
};
