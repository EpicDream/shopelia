
/////////////////////////////////////////////////////////////////////
//              SET CONTSTANTS AND GLOBOL VARIABLES
/////////////////////////////////////////////////////////////////////

TEST_ENV = true;
if (TEST_ENV) {
  SHOPELIA_DOMAIN = "http://localhost:3000"
} else {
  SHOPELIA_DOMAIN = "http://www.shopelia.fr"
}
PRODUCT_SHIFT_URL = SHOPELIA_DOMAIN + "/humanis/products/shift";
PRODUCT_UPDATE_URL = SHOPELIA_DOMAIN + "/humanis/products/";

var tasks = {},
    mappings = {};

/////////////////////////////////////////////////////////////////////
//                      ON CHROME EVENTS
/////////////////////////////////////////////////////////////////////

// On extension button clicked, start Ariane on this page.
chrome.browserAction.onClicked.addListener(function(tab) {
  console.log("Button pressed, going to load Ariane on tab", tab.id);
  initTabVariables(tab.id, {url: tab.url});
  load_ariane(tab.id);
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
    getProductUrlToExtract(tabId);
  } else if (msg.setMapping != undefined) {
    mappings[tabId][msg.fieldId] = {path: msg.path, context: msg.context};
  }
});

// On shortcuts emited, transmit it to contentscript.
chrome.commands.onCommand.addListener(function(command) {
  chrome.tabs.getSelected(function(tab) {
    chrome.tabs.sendMessage(tab.id, command);
  });
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
    initTabVariables(tabId, hash);
    chrome.tabs.update(tabId, {url: hash.url});
  });
};

//
function initTabVariables(tabId, hash) {
  var uri = new Uri(hash.url);
  tasks[tabId] = hash;
  tasks[tabId].host = uri.host();
  mappings[tabId] = {};
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
function send_finished_statement(tabId, reason) {
  $.ajax({
    type : "PUT",
    url: PRODUCT_UPDATE_URL+tasks[tabId].id,
    contentType: 'application/json',
    data: JSON.stringify({
      verb: reason ? 'bounce' : 'success',
      mapping: mappings[tabId],
      reason: reason
    })
  });
  delete tasks[tabId];
  delete mappings[tabId];
};

// Inject libraries and contentscript into the page.
function load_ariane(tabId) {
  chrome.tabs.executeScript(tabId, {file:"lib/underscore-min.js"});
  chrome.tabs.executeScript(tabId, {file:"lib/html_utils.js"});
  chrome.tabs.insertCSS(tabId, {file:"assets/contentscript.css"});
  chrome.tabs.executeScript(tabId, {file:"lib/jquery-1.9.1.min.js"}, function() {
    chrome.tabs.executeScript(tabId, {file:"lib/jquery-ui-1.10.3.custom.min.js"}, function() {
      chrome.tabs.executeScript(tabId, {file:"controllers/toolbar_contentscript.js"}, function() {
        chrome.tabs.executeScript(tabId, {file:"controllers/mapping_contentscript.js"}, function() {
          console.log("Ariane loaded !");
        });
      });
    });
  });
};
