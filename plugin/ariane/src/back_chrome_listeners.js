//
// Author : Vincent RENAUDINEAU
// Created : 2013-08-26

require(['ariane', 'logger'], function(ariane, logger) {

"use strict";

  var SATURN_EXTENSION_ID = "nhledioladlcecbcfenmdibnnndlfikf";

  var port = chrome.runtime.connect(SATURN_EXTENSION_ID);
  port.onMessage.addListener(function(msg) {
    chrome.storage.local.get('crawlings', function(hash) {
      hash.crawlings[msg.url][msg.kind] = msg.versions[0];
      chrome.storage.local.set(hash);
      chrome.tabs.sendMessage(msg.tabId, {action: msg.kind+'Crawl'});
    });
  });

  // On extension button clicked, start Ariane on this tab and url.
  chrome.browserAction.onClicked.addListener(function(tab) {
    logger.info("Button pressed, going to load Ariane on tab", tab.id);
    ariane.init(tab, tab.url);
  });

  // On page reload, restart Ariane if it was started on this tab and host before.
  // Clean the data for this tab if host has changed.
  chrome.tabs.onUpdated.addListener(function(tabId, changeInfo) {
    if (changeInfo.status === "complete") {
      chrome.storage.local.get('openTabs', function(hash) {
        if (hash.openTabs[tabId] === undefined)
          return;
        logger.debug("Load complete for tab", tabId);
        ariane.loadContentScript(tabId);
      });
    }
  });

  // On contentscript message to background.
  chrome.extension.onMessage.addListener(function(msg, sender, response) {
    if (sender.id != chrome.runtime.id) {
      logger.warn("Message rejected", msg, "from sender", sender);
      return;
    }
    var tabId = sender.tab.id;
    if (msg.action === 'launchAriane') {
      chrome.tabs.create({}, function(tab) {
        ariane.init(tab, msg.url);
        port.postMessage({tabId: tab.id, url: msg.url, kind: 'initial'});
      });
    } else if (msg.action === 'crawlPage') {
      delete msg.action;
      msg.tabId = tabId;
      port.postMessage(msg);
    } else if (msg.action === "finish" || msg.action === "abort") {
      ariane.sendFinishedStatement(tabId, msg.reason);
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
    ariane.clean(tabId, false);
  });

});