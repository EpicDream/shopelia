
require(['src/crawler', "satconf"], function(Crawler) {
  "use strict";

chrome.extension.onMessage.addListener(function(hash, sender, callback) {
  if (sender.id != chrome.runtime.id) return;
  console.debug("ProductCrawl task received", hash);
  var result = Crawler.doNext(hash.action, hash.mapping, hash.option, hash.value);
  if (hash.action == "setOption")
    setTimeout(goNextStep, satconf.DELAY_BETWEEN_OPTIONS);
  if (callback)
    callback(result);
});

function goNextStep() {
  chrome.extension.sendMessage("nextStep");
}

// To handle redirection, that throws false 'complete' state.
$(document).ready(function() {
  setTimeout(goNextStep, 100);
});

var script = document.createElement("script");
script.type = "text/javascript";
script.innerText = "window.alert = function() {};";
document.head.appendChild(script);

});
