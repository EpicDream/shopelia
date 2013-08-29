SHOPELIA_DOMAIN = "http://localhost:3000"
ORDER_SHIFT_URL = SHOPELIA_DOMAIN + "/humanis/orders/shift";
ORDER_UPDATE_URL = SHOPELIA_DOMAIN + "/humanis/orders/";
PRODUCT_SHIFT_URL = SHOPELIA_DOMAIN + "/humanis/product/shiftProduct";
PRODUCT_UPDATE_URL = SHOPELIA_DOMAIN + "/humanis/product/";
MAPPING_URL = SHOPELIA_DOMAIN + "/humanis/mapping";

var tasks = {},
    toLoad = {},
    billings = {},
    autofills = {},
    events = {},
    currentSteps = {},
    bg = chrome.extension.getBackgroundPage(),
    clipboardholder = bg.document.getElementById("clipboardholder");

// On extension button clicked.
chrome.browserAction.onClicked.addListener(function(tab) {
  console.log("Button pressed, going to load Kanaveral..");
  // getOrder(tab.id);
  load_kanaveral(tab.id);
});

// On page reload.
chrome.tabs.onUpdated.addListener(function(tabId, changeInfo) {
  if (changeInfo.status == "loading" && changeInfo.url) {
    var uri = new Uri(changeInfo.url);
    if (toLoad[tabId] && uri.host() != toLoad[tabId]) {
      clear_tab(tabId);
      console.log("Quit Kanaveral. Good bye !");
    }
  } else if (changeInfo.status == "complete" && toLoad[tabId]) {
    load_kanaveral(tabId);
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
  if (msg == "getTask") {
    var task = currentSteps[tabId] == 'crawl' ? 'crawl' : 'order';
    response({task: task, data: tasks[tabId], currentStep: currentSteps[tabId], autofill: autofills[tabId]});
  } else if (msg == "finish") {
    send_finished_statement(tabId)
    getOrder(tabId);
  } else if (msg.abort != undefined) {
    send_aborted_statement(tabId, msg.abort);
    getOrder(tabId);
  } else if (msg.copy != undefined) {
    clipboardholder.style.display = "block";
    clipboardholder.value = msg.copy;
    clipboardholder.select();
    bg.document.execCommand("Copy");
    clipboardholder.style.display = "none";
    console.debug("Content copied to clipboard :", msg.copy);
  } else if (msg.setCurrentStep != undefined) {
    change_step(tabId, msg.setCurrentStep);
  } else if (msg.setValue != undefined) {
    billings[tabId] = billings[tabId] || {};
    billings[tabId][msg.for] = msg.with;
    add_event(tabId, {step: "extract", context: msg.context, key: msg.for});
  } else if (msg.addEvent != undefined) {
    add_event(tabId, msg.event);
    var action = msg.event.action;
    if (action == "fill" || action == "tick" || action == "untick" || action == "click_on_radio" || action == "select")
      add_autofill(tabId, msg.event);
  }
});

// Change and store the current step.
// If the new step is "extract" load the product url.
function change_step(tabId, current_step) {
  var previous = currentSteps[tabId];
  currentSteps[tabId] = current_step;
  if (current_step == "extract" && previous != "extract" && previous != "add_product")
    chrome.tabs.update(tabId, {url: tasks[tabId].order.products_urls[0]});
};

// Store an event as a tuple (current_step, action, context, argument).
function add_event(tabId, event) {
  console.log("add_event", event);
  events[tabId] = events[tabId] || [];
  events[tabId].push(event);
};

// Store an autofill event.
// It's only a context for a cuple step/argument.
function add_autofill(tabId, event) {
  console.debug("add_autofill", event);
  autofills[tabId] = autofills[tabId] || {};
  autofills[tabId][event.step] = autofills[tabId][event.step] || {};
  autofills[tabId][event.step][event.keys] = autofills[tabId][event.step][event.keys] || [];
  autofills[tabId][event.step][event.keys].push(event.context);
};

// Get from Shopelia the next order to process.
function getOrder(tabId) {
  console.debug("Going to get order for tab", tabId);
  jq191.ajax({
    type : "GET",
    url: ORDER_SHIFT_URL,
    dataType: "json"
  }).done(function(hash) {
    console.debug("Get order for tab", tabId, ":", hash);
    if (hash)
      open_order(tabId, hash);
    else
      getProductUrlToExtract(tabId);
  }).fail(function(err) {
    console.error("When getting order for tab", tabId, ":", err);
  });
};

// Lunch Kanaveral into 'order' mode with the host url of the products loaded.
function open_order(tabId, order) {
  var urls = order.order.products_urls;
  if (urls.length == 0)
    return;
  var uri = new Uri(urls[0]);
  toLoad[tabId] = uri.host();
  tasks[tabId] = order;
  console.debug("Going to get autofill for tab", tabId, "and host", uri.host());
  jq191.ajax({
    type : "GET",
    url: MAPPING_URL+"?host="+uri.host(),
    dataType: "json"
  }).done(function(hash) {
    console.debug("Get autofill for tab", tabId, ":", hash);
    autofills[tabId] = hash || {};
  }).always(function() {
    console.debug("Open order at", uri);
    chrome.tabs.update(tabId, {url: uri.origin()});
  });
};

function send_finished_statement(tabId) {
  var url = currentSteps[tabId] == 'crawl' ? PRODUCT_UPDATE_URL : ORDER_UPDATE_URL;
  jq191.ajax({
    type : "PUT",
    url: url+tasks[tabId].session.uuid,
    data: {verb: 'success', params: {events: events[tabId], billing: billings[tabId]}}
  });
  clear_tab(tabId);
};

function send_aborted_statement(tabId, reason) {
  var url = currentSteps[tabId] == 'crawl' ? PRODUCT_UPDATE_URL : ORDER_UPDATE_URL;
  jq191.ajax({
    type : "PUT",
    url: url+tasks[tabId].session.uuid,
    data: {verb: 'bounce', params: {reason: reason, events: events[tabId], billing: billings[tabId]}}
  });
  clear_tab(tabId);
};

function clear_tab(tabId) {
  delete tasks[tabId];
  delete toLoad[tabId];
  delete billings[tabId];
  delete autofills[tabId];
  delete events[tabId];
  delete currentSteps[tabId];
};
