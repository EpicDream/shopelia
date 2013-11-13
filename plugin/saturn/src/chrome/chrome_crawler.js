
require(['chrome_logger', 'crawler', "satconf"], function(logger, Crawler) {
  "use strict";

logger.level = logger[satconf.log_level];

chrome.extension.onMessage.addListener(function(hash, sender, callback) {
  if (sender.id != chrome.runtime.id) return;
  logger.debug("ProductCrawl task received", hash);
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
    waitAjax();
  if (callback)
    callback(result);
});

function goNextStep() {
  chrome.extension.sendMessage("nextStep");
}

function waitAjax() {
  if (location.host.search(/amazon.fr$/) !== -1) {
    if (document.getElementById('prime_feature_div').style.opacity !== '')
      setTimeout(waitAjax, 100);
    else
      goNextStep();
  } else {
    // console.log('Neither jQuery nor Prototype, wait some time...');
    setTimeout(goNextStep, satconf.DELAY_BETWEEN_OPTIONS);
    // logger.debug("in contentscript, going to send 'waitAjax' msg.");
    // window.postMessage('waitAjax', '*');
  }
}

window.addEventListener("message", function(event) {
  if (event.source !== window || event.data !== "ajaxFinished")
    return;
  // logger.debug("in contentscript, 'ajaxFinished' msg received.");
  goNextStep();
}, false);

// Add a script to header to set in page context window.alert = null.
// Also add a waitAjax method to survey jQuery and Prototype Ajax pool.
var script = document.createElement("script");
script.type = "text/javascript";
script.innerHTML = "(function () {"+
  "window.alert = function() {};\n" +
  "function ajaxDone() {\n"+
    "waitAjaxTimer = undefined;" +
    "window.postMessage('ajaxFinished', '*');"+
  "}\n" +
  "var DELAY_BETWEEN_OPTIONS = " + satconf.DELAY_BETWEEN_OPTIONS + "," +
    "waitAjaxTimer;\n"+
  "function waitAjax() {\n"+
    // "var d = new Date(), time = d.toLocaleTimeString() + '.' + d.getMilliseconds();"+
    "if (waitAjaxTimer === undefined)"+
      "setTimeout(function () {if (waitAjaxTimer === undefined) return; clearTimeout(waitAjaxTimer); ajaxDone();}, 10000); /* wait max 10s */" +
    "if (typeof jQuery !== 'undefined') {\n"+
      "if (jQuery.active !== 0) {"+
        // "console.log(time, 'jQuery.active != 0, wait a little time...');"+
        "waitAjaxTimer = setTimeout(waitAjax, 100);"+
      "} else {"+
        // "console.log(time, 'jQuery.active == 0 !');"+
        "setTimeout(ajaxDone, 100);"+
      "}\n"+
    "} else if (typeof Ajax !== 'undefined') {\n"+
      "if (Ajax.activeRequestCount !== 0) {"+
        // "console.log(time, 'Ajax.activeRequestCount != 0, wait a little time...');"+
        "waitAjaxTimer = setTimeout(waitAjax, 100);"+
      "} else {"+
        // "console.log(time, 'Ajax.activeRequestCount == 0 !');"+
        "setTimeout(ajaxDone, 100);"+
      "}"+
    "} else {"+
      // "console.log(time, 'Neither jQuery nor Prototype, wait some time...');"+
      "setTimeout(ajaxDone, DELAY_BETWEEN_OPTIONS);"+
    "}\n"+
  "}\n"+
  "window.addEventListener('message', function(event) {"+
    "if (event.source !== window || event.data !== 'waitAjax')"+
      "return;"+
    "waitAjax();"+
  "}, false);\n"+
"})()";
document.head.appendChild(script);

// To handle redirection, that throws false 'complete' state.
$(document).ready(function() {
  setTimeout(goNextStep, 100);
});

});
