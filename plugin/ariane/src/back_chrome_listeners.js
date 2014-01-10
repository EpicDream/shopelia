// Back Chrome Listeners
// Author : Vincent RENAUDINEAU
// Created : 2013-08-26

require(['src/ariane', 'logger'], function(ariane, logger) {

"use strict";

  // var SATURN_EXTENSION_ID = "nbbhabeamfkgcikpihggcofhhilkhjpp";
  // var port = chrome.runtime.connect(SATURN_EXTENSION_ID);
  // port.onMessage.addListener(
  function onRuntimeMessage(msg) {
    if (msg.errorMsg)
      return alert(msg.errorMsg);
    chrome.storage.local.get('crawlings', function(hash) {
      if (msg.kind === 'initial')
        hash.crawlings[msg.url] = {initial: msg.versions[0]};
      else
        hash.crawlings[msg.url][msg.kind] = msg.versions[0];
      chrome.storage.local.set(hash);
      chrome.tabs.sendMessage(msg.tabId, {action: msg.kind+'Crawl', strategy: msg.strategy});
    });
  }
  // );

  var port, saturn_extension_id;
  chrome.management.getAll(function (extensions) {
    for (var i = 0; i < extensions.length; i++) {
      var ext = extensions[i];
      if (ext.name !== "Saturn")
        continue;
      saturn_extension_id = ext.id;
      port = chrome.runtime.connect(saturn_extension_id);
      port.onMessage.addListener(onRuntimeMessage);
    }
  });

  // On extension button clicked, start Ariane on this tab and url.
  chrome.browserAction.onClicked.addListener(function(tab) {
    logger.info("Button pressed, going to load Ariane on tab", tab.id);
    ariane.init(tab, tab.url);
    port.postMessage({tabId: tab.id, url: tab.url, kind: 'initial'});
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
    } else
      chrome.tabs.sendMessage(tabId, msg);
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