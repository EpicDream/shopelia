//
// Author : Vincent RENAUDINEAU

define([], function() {
  "use strict";
  
  // On shortcuts emited, transmit it to contentscript.
  chrome.commands.onCommand.addListener(function(command) {
    chrome.tabs.getSelected(function(tab) {
      chrome.tabs.sendMessage(tab.id, command);
    });
  });

  console.log("Toolbar module loaded !");
});