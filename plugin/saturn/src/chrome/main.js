// Tests for Saturn.
// Author : Vincent Renaudineau
// Created at : 2013-10-07

require(['logger', 'src/saturn', 'src/chrome/chrome_saturn', 'satconf'], function(logger, Saturn, ChromeSaturn) {

"use strict";

// Default to debug until Chrome propose tabs for each levels.
logger.level = logger[satconf.log_level];

var saturn = new ChromeSaturn();
window.saturn = saturn;

// On contentscript ask next step (next color/size tuple).
chrome.extension.onMessage.addListener(function(msg, sender, response) {
  if (sender.id != chrome.runtime.id || ! sender.tab || ! saturn.sessions[sender.tab.id])
    return;
  if (msg == "nextStep" && saturn.sessions[sender.tab.id].then)
    saturn.sessions[sender.tab.id].then();
});

// On extension button clicked.
chrome.browserAction.onClicked.addListener(function(tab) {
  if (satconf.run_mode === "auto") {
    if (saturn.crawl) {
      logger.info("Button pressed, Saturn is paused.");
      saturn.pause();
    } else {
      logger.info("Button pressed, Saturn is resumed.");
      saturn.resume();
    }
  } else {
    logger.info("Button pressed, going to crawl current page...");
    saturn.parseCurrentPage(tab);
  }
});

chrome.tabs.onRemoved.addListener(function(tabId) {
  Saturn.prototype.closeTab.call(saturn, tabId);
});

// Inter-extension messaging. Usefull for Ariane.
chrome.extension.onConnectExternal.addListener(function(port) {
  if (port.sender.id !== "aomdggmelcianmnecnijkolfnafpdbhm")
    return logger.warning('Extension', port.sender.id, "try to connect to us");
  saturn.externalPort = port;
  port.onMessage.addListener(function(prod) {
    if (prod.tabId === undefined || prod.url === undefined)
      return saturn.sendError(prod, 'some fields are missing.');
    prod.extensionId = port.sender.id;
    prod.strategy = 'fast';
    prod.keepTabOpen = true;
    saturn.onProductReceived(prod);
  });
});

if (satconf.run_mode === 'auto')
  saturn.start();

});
