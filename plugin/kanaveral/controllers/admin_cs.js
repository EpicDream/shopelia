//
// Author : Vincent RENAUDINEAU
// Created : 2013-08-26

"use strict";

var elems = document.querySelectorAll(".kanaveral[data-uuid]");
for (var i = 0 ; i < elems.length; i++)
  elems[i].addEventListener("click", function() {
    chrome.extension.sendMassage({dest: 'kanaveral', action: 'launch', order_id: $(this).attr("data-uuid")});
  }, false);
