//
// Author : Vincent RENAUDINEAU
// Created : 2013-

define(['toolbar', 'copy', 'autofill', 'order'], function(tb, cp, af, od) {
  "use strict";

  var that = {states: {}},
      states = that.states;

  // On extension button clicked.
  chrome.browserAction.onClicked.addListener(function(tab) {
    console.log("Button pressed, going to load Kanaveral..");
    that.launchOnUrl(tab.id, tab.url);
  });

  // On page reload.
  chrome.tabs.onUpdated.addListener(function(tabId, changeInfo) {
    var state = states[tabId];
    if (changeInfo.status == "loading" && changeInfo.url) {
      var uri = new Uri(changeInfo.url);
      if (state && uri.host().match(state.host)) {
        that.clean(tabId);
        console.log("Quit Kanaveral. Good bye ! (tab="+tabId+")");
      }
    } else if (changeInfo.status == "complete" && state) {
      that.load_contentscript(tabId);
    }
  });

  // On contentscript message.
  chrome.extension.onMessage.addListener(function(msg, sender, response) {
    if (sender.id != chrome.runtime.id || ! msg.dest || msg.dest != 'kanaveral')
      return;

    console.debug("Message received", msg);
    var tabId = sender.tab.id;
    if (msg.action == "get") {
      response(states[tabId]);
    } else if (msg.action == "set") {
      states[tabId] = msg.state;
    }
  });

  //
  chrome.tabs.onRemoved.addListener(function(tabId, removeInfo) {
    if (! states[tabId]) return;
    that.clean(tabId);
  });

  //
  that.launch = function(tabId) {
    states[tabId] = {};
    od.getNewOrder(tabId).done(function(order) {
      var urls = order.order.products_urls;
      if (urls.length == 0)
        return console.error("No url in this order");
      that.launchOrder(tabId, order);
    });
  };

  //
  that.launchOnUrl = function(tabId, url) {
    var order = od.getTestOrder(tabId);
    order.order.products_urls = [url];
    af.getMerchantId(url).done(function(hash) {
      order.merchant_id = hash.id;
      that.launchOrder(tabId, order);
    });
  };

  //
  that.launchOrder = function(tabId, order) {
    states[tabId] = {};
    var uri = new Uri(order.order.products_urls[0]);
    states[tabId].host = uri.host().replace(/^www./, '');
    af.loadAutofill(tabId, order.merchant_id).always(function() {
      // Load merchant's BASE_URL
      that.load_contentscript(tabId);
    });
  };

  // Inject libraries and contentscript into the page.
  that.load_contentscript = function(tabId) {
    // Pas réussi à charger underscore en passant par require.js
    chrome.tabs.executeScript(tabId, {file: "lib/underscore.js"});
    chrome.tabs.executeScript(tabId, {file: "lib/require.js"}, function() {
      chrome.tabs.executeScript(tabId, {file: "controllers/main_cs.js"});
    });
    console.log("Kanaveral started !");
  };

  that.clean = function(tabId) {
    window.$lastState = states[tabId];
    delete states[tabId];
    af.clean(tabId);
    od.clean(tabId);
  };

  console.log("Kanaveral loaded !");

  return that;
});
