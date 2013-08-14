//
// Author : Vincent RENAUDINEAU

define(['jquery'], function($) {
  "use strict";

  var TEST_ENV = navigator.appVersion.match(/chromium/i) !== null;
  var LOCAL_ENV = true;

  if (LOCAL_ENV)
    var SHOPELIA_DOMAIN = "http://localhost:3000";
  else
    var SHOPELIA_DOMAIN = "https://www.shopelia.fr";

  var MAPPING_URL = "https://www.shopelia.fr/api/viking/merchants/";

  var that = {autofills: {}},
      autofills = that.autofills,
      merchants = {
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

  // On contentscript message.
  chrome.extension.onMessage.addListener(function(msg, sender, response) {
    if (sender.id != chrome.runtime.id || ! msg.dest || msg.dest != 'autofill')
      return;

    console.debug("Message received", msg);
    var tabId = sender.tab.id;
    var action = msg.action;
    if (action == "get")
      response(autofills[tabId].data.autofills);
    // else if (action == "fill" || action == "tick" || action == "untick" || action == "click_on_radio" || action == "select")
    else if (action == "set")
      that.addAutofill(tabId, msg.event);
    else if (action == "finish")
      that.saveAutofill(tabId);
  });

  that.loadAutofill = function(tabId, merchant_id) {
    if (typeof merchant_id == 'string' && isNaN(parseInt(merchant_id)))
      merchant_id = that.getMerchantId(merchant_id)
    if (! merchant_id)
      return console.log("Cannot retrieve merchant with id", merchant_id);

    autofills[tabId] = {};
    return $.ajax({
      type : "GET",
      url: MAPPING_URL+merchant_id,
      dataType: "json"
    }).done(function(hash) {
      console.debug("Get autofill for tab", tabId, ":", hash);
      autofills[tabId] = hash || {id: merchant_id};
      if (! autofills[tabId].data)
        autofills[tabId].data = {};
      if (! autofills[tabId].data.autofills)
        autofills[tabId].data.autofills = {};
    }).fail(function(err) {
      console.error("When getting autofill for tab", tabId, ":", err);
    });
  };

  // Store an autofill event.
  // It's only a context for a cuple step/argument.
  that.addAutofill = function(tabId, event) {
    console.debug("add_autofill", event);
    autofills[tabId].data.autofills[event.step] = autofills[tabId].data.autofills[event.step] || {};
    autofills[tabId].data.autofills[event.step][event.key] = autofills[tabId].data.autofills[event.step][event.key] || [];
    autofills[tabId].data.autofills[event.step][event.key].push(event.context);
  };

  that.optimize = function(tabId) {
    var h = autofills[tabId].data.autofills;
    for (var stepKey in h) {
      var step = h[stepKey];
      for (var fieldKey in step) {
        var contexts = step[fieldKey];
        // Si on a deux path identiques, le deuxième écrase le premier.
        // Pour chaque contexte en sens inverse,
        for (var i = contexts.length-1 ; i > 0 ; i--) {
          var c1 = contexts[i];
          if (c1 == null) continue;
          // si il y en a un autre avec ce path, on le supprime
          for (var j = i-1 ; j >= 0 ; j--) {
            var c2 = contexts[j];
            if (c2 == null) continue;
            if (c1.css = c2.css)
              contexts[j] = null;
          }
        }
        h[stepKey][fieldKey] = _.compact(h[stepKey][fieldKey]);
      }
    }
  };

  // Store an event as a tuple (current_step, action, context, argument).
  // that.addEvent = function(tabId, event) {
  //   console.log("add_event", event);
  //   events[tabId] = events[tabId] || [];
  //   events[tabId].push(event);
  // };


  that.saveAutofill = function(tabId) {
    console.log(that.optimize(tabId));
    // return $.ajax({
    //   type : "PUT",
    //   url: MAPPING_URL+autofills[tabId].merchant_id,
    //   contentType: "application/json",
    //   data: JSON.stringify(autofills[tabId])
    // }).fail(function(err) {
    //   console.error("When getting autofill for tab", tabId, ":", err);
    // }).always(function() {
    //   that.clean(tabId);
    // });
  };

  //
  that.clean = function(tabId) {
    window.$lastAutofill = autofills[tabId];
    delete autofills[tabId];
  };

  // Deprecated : Get merchant_id from uri.
  // Will be replaced by an api call on Shopelia/viking.
  that.getMerchantId = function(uri) {
    if (! (uri instanceof Uri))
      uri = new Uri(uri);
    var host = uri.host();
    while (host !== "") {
      if (merchants[host])
        return merchants[host];
      else
        host = host.replace(/^\w+(\.|$)/, '');
    }
    return undefined;
  };

  console.log("Autofill module loaded !");

  return that;
});
