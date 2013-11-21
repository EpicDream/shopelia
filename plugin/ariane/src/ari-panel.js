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
    iframe.style.display = 'none';
    iframe.onload = function () {
      iframe.style.display = '';
    };
    document.documentElement.appendChild(iframe);
  }

  init();

  panel.show = function() {
    iframe.classList.remove("ari-panel-hide");
    document.body.classList.add("ari-panel-body");
  };

  panel.hide = function() {
    iframe.classList.add("ari-panel-hide");
    document.body.classList.remove("ari-panel-body");
  };

  panel.toggle = function() {
    iframe.classList.toggle("ari-panel-hide");
    document.body.classList.toggle("ari-panel-body");
  };

  panel.isVisible = function() {
    return ! iframe.classList.contains('ari-panel-hide');
  };

  return panel;
});
