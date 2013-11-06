//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-24

define(['chrome_logger', 'mapping'], function(logger, Mapping) {
  "use strict";

  var ariane = {};

  // Init vars
  chrome.storage.local.set({openTabs: {}, mappings: {}, crawlings: {}});
  logger.level = logger.ALL;

  // Que ce soit via le bouton dans admin/viking ou via le bouton de l'extension.
  ariane.init = function(tab, url) {
    Mapping.load(url).done(function(mapping) {
      chrome.storage.local.get(['mappings', 'openTabs', 'crawlings'], function(hash) {
        if (! mapping) {
          alert("Fail to retrieve mapping. Retry.");
          return ariane.clean(tab.id);
        }
        logger.debug("Init Ariane for tab", tab.id, ", mapping", mapping, "and previous hash", hash);
        hash.openTabs[tab.id] = url;
        hash.mappings[url] = mapping.toObject();
        hash.crawlings[url] = {};
        chrome.storage.local.set(hash);
        ariane.loadContentScript(tab.id);
      });
    }).fail(function(err) {
      alert("Fail to retrieve mapping. Retry.");
      ariane.clean(tab.id);
    });
  };

  // Inject libraries and contentscript into the page.
  ariane.loadContentScript = function(tabId) {
    chrome.tabs.executeScript(tabId,
      {code: "require(['controllers/mapping_contentscript'], function(mapper) {mapper.start();});"}
    );
  };

  // Merge the new mapping with the old, send it to shopelia, and clean data for this tab.
  ariane.sendFinishedStatement = function(tabId, reason) {
    chrome.storage.local.get(['openTabs', "mappings"], function(hash) {
      var url = hash.openTabs[tabId];
      var mapping = hash.mappings[url];
      Mapping.save(mapping).done(function() {
        logger.debug("("+tabId+") New mapping #"+mapping.id+" sended.");
        ariane.clean(tabId, true);
      }).fail(function(err) {
        alert("Fail to send new mapping :", err);
      });
    });
  };

  // Clean data for this tab.
  // All data are saved in global variable $e for debugging purpose.
  ariane.clean = function(tabId, deleteTab) {
    chrome.storage.local.get(['openTabs', "mappings", "crawlings"], function(hash) {
      var url = hash.openTabs[tabId];
      if (url === undefined)
        return;
      delete hash.openTabs[tabId];
      delete hash.mappings[url];
      delete hash.crawlings[url];
      chrome.storage.local.set(hash);
    });
    if (deleteTab !== false)
      chrome.tabs.remove(tabId);
  };

  return ariane;
});
