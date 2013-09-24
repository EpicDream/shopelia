//
// Author : Vincent RENAUDINEAU

define(['jquery','toolbar','utils'], function($, tb) {
  "use strict";
  
  var that = {},
      jButtons = null;

  function setOrderValues(hash, ancestors) {
    if (ancestors === undefined)
      ancestors = [];
    for (var i in hash) {
      if (typeof hash[i] !== 'object') {
        var ancests = ancestors.concat([i]).join('-');
        that.orderValueHash[ancests] = hash[i];
        if (hash[i] === '')
          jButtons.filter("[data-id="+ancests+"]").prop("disabled", true);
      } else
        setOrderValues(hash[i], ancestors.concat([i]));
    }
  };

  tb.ready(function() {
    jButtons = $(tb.buttonElems);

    chrome.extension.sendMessage({dest: 'order', action: 'get'}, function(order) {
      console.debug("Order received", order);
      that.order = order;

      if (order && order.user && order.user.birthdate) {
        var date = order.user.birthdate;
        order.user.birthdate.full = sprintf("%02d/%02d/%04d", date.day, date.month, date.year);
      }
      that.orderValueHash = {};
      setOrderValues(order);
    });
  });
  
  return that;
});