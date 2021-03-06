//
// Author : Vincent RENAUDINEAU

define(['jquery', 'uri'], function($, Uri) {
  "use strict";

  var that = {orders: {}},
      orders = that.orders;

  var TEST_ENV = navigator.appVersion.match(/chromium/i) !== null;
  var LOCAL_ENV = true;

  if (LOCAL_ENV)
    var SHOPELIA_DOMAIN = "http://localhost:3000";
  else
    var SHOPELIA_DOMAIN = "https://www.shopelia.fr";

  var ORDER_URL = SHOPELIA_DOMAIN + "/humanis/orders/"

  // On contentscript message.
  chrome.extension.onMessage.addListener(function(msg, sender, response) {
    if (sender.id != chrome.runtime.id || ! msg.dest || msg.dest != 'order')
      return;

    console.debug("Message received", msg);
    var tabId = sender.tab.id;
    if (msg.action == "get") {
      response(orders[tabId]);
    } else if (msg.action == 'set_value') {
      orders[tabId].billing[msg.for] = msg.with;      
      // add_event(tabId, {step: "extract", context: msg.context, key: msg.for});
    }
  });

  // Get from Shopelia the next order to process.
  // If order_id is provided, get this one,
  // shift the next else.
  that.getNewOrder = function(tabId, order_id) {
    if (! order_id)
      order_id = "shift";
    console.debug("Going to get order", order_id, "for tab", tabId);
    return $.ajax({
      type : "GET",
      url: ORDER_URL + order_id,
      dataType: "json"
    }).done(function(hash) {
      console.debug("Get order for tab", tabId, ":", hash);
      initOrder(tabId, hash);
    }).fail(function(err) {
      console.error("When getting order for tab", tabId, ":", err);
    });
  };

  // Lunch Kanaveral into 'order' mode with the host url of the products loaded.
  function initOrder(tabId, order) {
    orders[tabId] = order;
    orders[tabId].billing = {};
    orders[tabId].product_idx = -1;
  };

  // Try to load the next product.
  // Return false if there is no next product.
  that.loadNextProduct = function(tabId) {
    orders[tabId].product_idx += 1;
    var idx = orders[tabId].product_idx;
    if (! orders[tabId].order.products[idx])
      return false;
    var url = orders[tabId].order.products[idx].url;
    chrome.tabs.update(tabId, {url: url});
    return true;
  };

  //
  that.sendFinished = function(tabId, reason) {
    return $.ajax({
      type : "PUT",
      url: ORDER_URL+orders[tabId].session.uuid,
      data: JSON.stringify({verb: (reason ? 'bounce' : 'success'), params: {billing: orders[tabId].billing, reason: reason}})
    });
    clean(tabId);
  };

  that.clean = function(tabId) {
    if (! orders[tabId]) return;
    window.$lastOrder = orders[tabId];
    delete orders[tabId];
  };

  that.getTestOrder = function(tabId) {
    var hash = { 
      'account': {'login': 'timmy001@yopmail.com', 'password': 'shopelia2013', new_account: false},
      'session': {'uuid': 'fake-uuid-for-tests'},
      'order': {
        'products': [],
        'credentials': {
          'holder': 'TIMMY DUPONT',
          'number': '401290129019201',
          'exp_month': 1,
          'exp_year': 2014,
          'cvv': 123}
      },
      'user': {
        'birthdate': {'day': 1, 'month': 4, 'year': 1985},
        'gender': 0,
        'address': {
          'address_1': '12 rue des lilas',
          'address_2': '',
          'first_name': 'Timmy',
          'last_name': 'Dupont',
          'additionnal_address': '',
          'zip': '75019',
          'city': 'Paris',
          'mobile_phone': '0634562345',
          'land_phone': '0134562345',
          'country': 'France'}
      }
    };
    console.debug("Get test order for tab", tabId, ":", hash);
    initOrder(tabId, hash);
    return hash;
  };

  console.log("Order module loaded !");  
  return that;
});