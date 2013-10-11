//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-25

define(function() {
  "use strict";

  var panel = {},
      iframe;

  function init() {
    // Create DIV
    iframe = document.createElement('iframe');
    iframe.id = "ari-panel";
    iframe.src = chrome.runtime.getURL('views/panel.html') + "#fieldsPage";
    iframe.classList.add("ari-panel-hide");
    document.documentElement.appendChild(iframe);
  }

  init();

  panel.show = function() {
    if (! iframe) // Fix to fast .js files load.
      return setTimeout(panel.show().bind(this), 100);

    iframe.class = "";
    document.body.classList.add("ari-panel-body");
  };

  panel.hide = function() {
    iframe.class = "ari-panel-hide";
    document.body.classList.remove("ari-panel-body");
  };

  panel.toggle = function() {
    iframe.classList.toggle("ari-panel-hide");
    document.body.classList.toggle("ari-panel-body");
  };

  return panel;
});
