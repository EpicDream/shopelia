//
// Author : Vincent RENAUDINEAU

define([], function() {
  "use strict";

  var bg = chrome.extension.getBackgroundPage(),
      clipboardholder = bg.document.getElementById("clipboardholder");

  // On contentscript message.
  chrome.extension.onMessage.addListener(function(msg, sender, response) {
    if (sender.id != chrome.runtime.id || ! msg.dest || msg.dest != "copy" || msg.value === undefined)
      return;

    console.debug("In back_copy: Message received", msg);

    clipboardholder.style.display = "block";
    clipboardholder.value = msg.value;
    clipboardholder.select();
    bg.document.execCommand("Copy");
    clipboardholder.style.display = "none";
    console.debug("Content copied to clipboard :", msg.value);
  });
  
  console.log("Copy module loaded !");
});
