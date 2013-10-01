//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-24

define('ariane', ['logger', 'viking'], function(logger, viking) {
  "use strict";

  var ariane = {};

  // Init vars
  chrome.storage.local.set({openTabs: {}, mappings: {}, crawlings: {}});
  logger.level = logger.ALL;

  // Que ce soit via le bouton dans admin/viking ou via le bouton de l'extension.
  ariane.init = function(tab, url) {
    viking.loadMapping(url, function(merchantHash) {
      chrome.storage.local.get(['mappings', 'openTabs', 'crawlings'], function(hash) {
        if (! merchantHash) {
          alert("Fail to retrieve mapping. Retry.");
          return ariane.clean(tab.id);
        } else if (typeof merchantHash.data !== 'object') {
          logger.info("Merchant "+merchantHash.id+" is a new merchant.");
          merchantHash.data = viking.initMerchantData(url);
          chrome.tabs.update(tab.id, {url: url});
        }
        logger.debug("Init Ariane for tab", tab.id, ", merchantHash", merchantHash, "and previous hash", hash);
        hash.openTabs[tab.id] = url;
        hash.mappings[url] = merchantHash;
        hash.crawlings[url] = {};
        chrome.storage.local.set(hash);
      });
    }, function(err) {
      alert("Fail to retrieve mapping. Retry.");
      ariane.clean(tab.id);
    });
  };

  // Inject libraries and contentscript into the page.
  ariane.loadContentScript = function(tabId) {
    chrome.tabs.executeScript(tabId,
      {code: "require(['mapper'], function(mapper) {mapper.start();});"}
    );
  };

  // Merge the new mapping with the old, send it to shopelia, and clean data for this tab.
  ariane.sendFinishedStatement = function(tabId, reason) {
    chrome.storage.local.get(['openTabs', "mappings"], function(hash) {
      var url = hash.openTabs[tabId];
      var mapping = hash.mappings[url];
      $.ajax({
        type : "PUT",
        url: viking.MAPPING_URL+'/'+mapping.id,
        contentType: 'application/json',
        data: JSON.stringify(mapping)
      }).done(function() {
        logger.debug("("+tabId+") New mapping sended.");
        ariane.clean(tabId, true);
      }).fail(function(err) {
        alert("Fail to send new mapping :", err);
      });
    });
  };

  // Clean data for this tab.
  // All data are saved in global variable $e for debugging purpose.
  ariane.clean = function(tabId, deleteTab) {
    chrome.storage.local.get(['openTabs', "mappings"], function(hash) {
      var url = hash.openTabs[tabId];
      if (url === undefined)
        return;
      delete hash.openTabs[tabId];
      delete hash.mappings[url];
      chrome.storage.local.set(hash);
    });
    if (deleteTab !== false)
      chrome.tabs.remove(tabId);
  };

  return ariane;
});
