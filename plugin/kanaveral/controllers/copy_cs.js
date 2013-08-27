//
// Author : Vincent RENAUDINEAU

define(['jquery', 'toolbar', 'order'], function($, tb, od) {
  "use strict";
  
  var that = {};

  function onButtonClicked(event) {
    var e = $(event.currentTarget);
    console.debug(e.attr('data-id'), od.orderValueHash[e.attr('data-id')]);
    chrome.extension.sendMessage({dest: 'copy', value: od.orderValueHash[e.attr('data-id')]});
  };

  tb.ready(function() {
    $(tb.buttonElems).filter(":not(.extractor)").click(onButtonClicked);
  });

  return that;
});
