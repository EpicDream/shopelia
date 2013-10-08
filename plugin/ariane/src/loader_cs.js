//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-24

(function() {

"use strict";

function onSomethingClicked(event) {
  var e = event.target;
  if (e.tagName !== 'BUTTON' || ! e.getAttribute('data-url'))
    return;
  chrome.extension.sendMessage({action: 'launchAriane', url: event.target.getAttribute('data-url')});
}

document.addEventListener('click', onSomethingClicked);

})();
