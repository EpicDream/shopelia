
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
  "toysrus.fr" : "7"
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
  if (msg == "finish" || msg.abort != undefined) {
    send_finished_statement(tabId, msg.abort)
    //getProductUrlToExtract(tabId);
  } else if (msg.setMapping != undefined) {
    tasks[tabId].currentMap[msg.fieldId] = msg;
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
  delete tasks[tabId];
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
  chrome.tabs.executeScript(tabId, {file:"lib/underscore-min.js"});
  chrome.tabs.executeScript(tabId, {file:"lib/css_struct.js"});
  chrome.tabs.executeScript(tabId, {file:"lib/path_utils.js"});
  chrome.tabs.executeScript(tabId, {file:"lib/html_utils.js"});
  chrome.tabs.insertCSS(tabId, {file:"assets/contentscript.css"});
  chrome.tabs.executeScript(tabId, {file:"lib/jquery-1.9.1.min.js"}, function() {
    chrome.tabs.executeScript(tabId, {file:"lib/jquery-ui-1.10.3.custom.min.js"}, function() {
      chrome.tabs.executeScript(tabId, {file:"controllers/toolbar_contentscript.js"}, function() {
        chrome.tabs.executeScript(tabId, {file:"controllers/mapping_contentscript.js"}, function() {
          chrome.tabs.sendMessage(tabId, {mapping: tasks[tabId].mapping});
          console.log("Ariane loaded !");
        });
      });
    });
  });
};

//
function send_finished_statement(tabId, reason) {
  if (! tasks[tabId].fullMapping[tasks[tabId].mapHost])
    tasks[tabId].fullMapping[tasks[tabId].mapHost] = {};
  var mapping = tasks[tabId].fullMapping[tasks[tabId].mapHost];
  var currentMap = tasks[tabId].currentMap;
  for (var key in jQuery.extend({}, mapping, currentMap)) {
    if (! currentMap[key])
      continue;
    if (! mapping[key])
      mapping[key] = {path: [currentMap[key].path]};
    else if (mapping[key].path instanceof Array)
      mapping[key].path.push(currentMap[key].path);
    else
      mapping[key].path = [mapping[key].path, currentMap[key].path];

    if (! mapping[key].context)
      mapping[key].context = [currentMap[key].context];
    else if (mapping[key].context instanceof Array)
      mapping[key].context.push(currentMap[key].context);
    else
      mapping[key].context = [mapping[key].context, currentMap[key].context];
  }

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
