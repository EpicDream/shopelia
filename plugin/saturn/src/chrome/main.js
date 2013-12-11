// Tests for Saturn.
// Author : Vincent Renaudineau
// Created at : 2013-10-07

require(['chrome_logger', 'src/saturn', 'src/chrome/chrome_saturn', 'satconf'], function(logger, Saturn, ChromeSaturn) {

"use strict";

// Default to debug until Chrome propose tabs for each levels.
logger.level = logger[satconf.log_level];

var saturn = new ChromeSaturn();
window.saturn = saturn;

// On contentscript ask next step (next color/size tuple).
chrome.extension.onMessage.addListener(function(msg, sender, response) {
  if (sender.id != chrome.runtime.id || ! sender.tab || ! saturn.sessions.byTabId[sender.tab.id])
    return;
  if (msg == "nextStep" && saturn.sessions.byTabId[sender.tab.id].then)
    saturn.sessions.byTabId[sender.tab.id].then();
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
    return logger.warn('Extension', port.sender.id, "try to connect to us");
  saturn.externalPort = port;
  port.onMessage.addListener(function(prod) {
    if (prod.tabId === undefined || prod.url === undefined)
      return saturn.sendError(prod, 'some fields are missing.');
    prod.extensionId = port.sender.id;
    prod.strategy = prod.strategy || 'fast';
    prod.keepTabOpen = true;
    saturn.onProductReceived(prod);
  });
});

// Methods to restart adBlock periodically.
var adBlock = saturn.adBlock = {
  id: "cfhdojbkjhnklbpkdaibdccddilifddb",
  lastRestart: Date.now(),
  restart: function (callback) {
    logger.debug("AdBlock : restart !");
    this.onRestartCb = callback;
    if (this.canRestart()) {
      saturn.pause();
      this.disable();
    } else
      setInterval(function () {
        adBlock.restart();
      }, 1000*60*5);
  },
  disable: function () {logger.debug("Disable AdBlock"); chrome.management.setEnabled(this.id, false);},
  enable: function () {logger.debug("Enable AdBlock"); chrome.management.setEnabled(this.id, true, this.onRestart);},
  onRestart: function () {
    logger.debug("AdBlock restarted !");
    saturn.resume();
    adBlock.lastRestart = Date.now();
    if (adBlock.restartEveryDelay) {
      adBlock.restartIn(adBlock.restartEveryDelay);
    } else if (adBlock.nextRestartDate) {
      adBlock.nextRestartDate += 1000*3600*24;
      adBlock.restartIn(adBlock.nextRestartDate - Date.now());
    }
    if (adBlock.onRestartCb)
      adBlock.onRestartCb();
  },
  canRestart: function () { return saturn.canRestart(); },
  restartIn: function (ms) {
    setTimeout(function() {
      adBlock.restart();
    }, ms);
  },
  restartAt: function (hour, min) {
    var now = new Date();
    this.nextRestartDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, min || 0, 0, 0);
    if (this.nextRestartDate < now)
      this.nextRestartDate += 1000*3600*24;
    this.restartIn(this.nextRestartDate - now);
  },
  restartEvery: function (ms) {
    if (! ms) return;
    this.restartEveryDelay = ms;
    this.restartIn(this.restartEveryDelay);
  },
};
chrome.management.onDisabled.addListener(function (extension) {
  if (extension.id === adBlock.id)
    adBlock.enable();
});
// Restart every 12h
adBlock.restartEvery(satconf.ADBLOCK_RESTART_DELAY);

// Methods to restart Chrome periodically
saturn.restartChrome = function () {
  if (saturn.canRestart()) {
    logger.debug("Chrome : restart !");
    chrome.tabs.create({url: "chrome://restart/"});
  } else {
    setTimeout(function() {
      saturn.restartChrome();
    }, 1000*60*5); // Retry every 5 min
  }
};
saturn.lastChromeRestart = Date.now();
if (satconf.CHROME_RESTART_DELAY)
  setTimeout(function() {
    saturn.restartChrome();
  }, satconf.CHROME_RESTART_DELAY);

if (satconf.run_mode === 'auto')
  saturn.start();

});
