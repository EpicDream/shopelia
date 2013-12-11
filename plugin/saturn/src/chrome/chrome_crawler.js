// ChromeLogger
// Author : Vincent RENAUDINEAU
// Created : 2013-11-06

require(['chrome_logger', 'crawler', 'src/helper', "satconf"], function(logger, Crawler, helper) {
  "use strict";

window.Crawler = Crawler;
logger.level = logger[satconf.log_level];
var h = helper.get(location.href),
  crawlHelper = h && h.crawler;

chrome.extension.onMessage.addListener(function(hash, sender, callback) {
  if (sender.id != chrome.runtime.id) return;
  logger.debug("ProductCrawl", hash.action, "task received", hash);
  var key = "option"+(hash.option),
    result;
  switch(hash.action) {
    case "getOptions":
      result = hash.mapping[key] ? Crawler.getOptions(hash.mapping[key].paths) : [];
      break;
    case "setOption":
      result = Crawler.setOption(hash.mapping[key].paths, hash.value);
      break;
    case "crawl":
      result = Crawler.crawl(hash.mapping);
      break;
    default:
      logger.error("Unknow command", action);
      result = false;
  }

  if (hash.action == "setOption")
    setTimeout(waitAjax, 1000); // wait minimal to let page reload on url change
  if (callback)
    callback(result);
});

Crawler.onbeforeunloadBack = window.onbeforeunload;
window.onbeforeunload = function() {
  Crawler.pageWillBeUnloaded = true;
  if (typeof Crawler.onbeforeunloadBack === 'function')
    return Crawler.onbeforeunloadBack();
};

function goNextStep() {
  if (! Crawler.pageWillBeUnloaded)
    chrome.extension.sendMessage("nextStep");
}

function waitAjax() {
  if (location.host.search(/amazon.fr$/) !== -1) {
    var elem = document.getElementById('prime_feature_div');
    if (elem && elem.style.opacity !== '')
      setTimeout(waitAjax, 100);
    else
      goNextStep();
  } else if (! Crawler.pageWillBeUnloaded) {
    setTimeout(goNextStep, satconf.DELAY_BETWEEN_OPTIONS);
  }
}

// To handle redirection, that throws false 'complete' state.
$(document).ready(function() {
  if (crawlHelper && crawlHelper.at_load)
    crawlHelper.at_load(goNextStep);
  else
    setTimeout(goNextStep, 100);
});

});
