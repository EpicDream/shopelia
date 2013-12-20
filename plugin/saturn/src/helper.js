// Saturn Merchant Helper
// Author : Vincent Renaudineau
// Created at : 2013-09-05

define(['logger', 'core_extensions'], function(logger) {

"use strict";

var RueducommerceHelper = {
  crawler: {
    atLoad: function(callback) {
      var popup = document.querySelector("#ox-is-skip");
      if (popup)
        popup.click(); // close
      setTimeout(callback, 1000);
    },
  },
};

var LuisaviaromaHelper = {
  session: {
    init: function (session) {
      session.oldCrawl = session.crawl;
      session.crawl = this.crawl;
    },
    crawl: function() {
      setTimeout(this.oldCrawl.bind(this), 1000);
    }
  }
};

var BrandalleyHelper = {
  crawler: {
    atLoad: function(callback) {
      setTimeout(function () {
        var popup = document.querySelector("#closePopUp");
        if (popup)
          popup.click(); // close
        callback();
      }, 1000);
    },
  },
};

var Helper = {
  get: function (url, context) {
    if (! url) {
      return null;
    } else if (url.search(/^https?:\/\/www\.rueducommerce\.fr/) !== -1) {
      return RueducommerceHelper[context];
    } else if (url.search(/^https?:\/\/www\.luisaviaroma\.com/) !== -1) {
      return LuisaviaromaHelper[context];
    } else if (url.search(/^https?:\/\/www\.brandalley\.fr/) !== -1) {
      return BrandalleyHelper[context];
    }
  }
};

return Helper;

});

/*
On remplace le then,
Dans le then on vérifie qu'il y a bien filter=10, sinon, on rajoute, et on recharge.
Comment vérifier qu'il y a bien le filter=10 ?
chrome.query ?
*/