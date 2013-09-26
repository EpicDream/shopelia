//
// Author : Vincent RENAUDINEAU
// Created : 2013-08-26

require(['ariane', 'logger'], function(ariane, logger) {

"use strict";

  // On extension button clicked, start Ariane on this tab and url.
  chrome.browserAction.onClicked.addListener(function(tab) {
    logger.info("Button pressed, going to load Ariane on tab", tab.id);
    ariane.init(tab);
  });

  // On page reload, restart Ariane if it was started on this tab and host before.
  // Clean the data for this tab if host has changed.
  chrome.tabs.onUpdated.addListener(function(tabId, changeInfo) {
    if (changeInfo.status == "complete") {
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
    if (msg == "finish" || msg.abort !== undefined) {
      ariane.sendFinishedStatement(tabId, msg.abort);
    } else if (msg.action == 'launchAriane') {

      chrome.tabs.create({url: msg.url}, function(tab) {
        ariane.init(tab);
      });
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