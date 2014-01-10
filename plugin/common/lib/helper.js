// Saturn Merchant Helper
// Author : Vincent Renaudineau
// Created at : 2013-09-05

define(['jquery', 'logger', 'core_extensions'], function($, logger) {

"use strict";

var AmazonFrHelper = {
  crawler: {
    waitAjax: function(callback) {
      var elem = $('#prime_feature_div').last()[0]; //#price_feature_div, #availability_feature_div, #ftMessage,
      if (! elem) {
        logger.warn("no elem found to test opacity !");
        setTimeout(callback, satconf.DELAY_BETWEEN_OPTIONS);
      } else if (elem.style.opacity !== '') {
        setTimeout(function () {this.waitAjax(callback);}.bind(this), 100);
      } else
        callback();
    },
  },
};

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
  crawler: {
    atLoad: function(callback) {
      setTimeout(callback, 1000);
    },
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

var ZaraHelper = {
  crawler: {
    atLoad: function(callback) {
      var btn = document.querySelector("#wwButtom");
      if (! btn)
        return callback();
      btn.click(); // Go to selected store
      setTimeout(function () {
        callback();
      }, 1000);
    },
  },
};

var PlacedestendancesHelper = {
  crawler: {
    atLoad: function(callback) {
      var select = document.querySelector("#taille_id");
      if (! select)
        return callback();
      select.click(); // open and load available sizes
      setTimeout(function () {
        callback();
      }, 1000);
    },
  },
};

var SpartooHelper = {
  crawler: {
    parseField: {
      rating: function (elems) {
        return elems.toArray().map(function(e) {
          var src = e.src,
            m;
          if (src && (m = src.match(/stars_(\d)/)))
            src = m[1];
          return src;
        });
      },
    }
  },
};

var ShopbopHelper = {
  crawler: {
    parseField: {
      availability: function (elems) {
        if (elems.length === 1 && elems[0].id === "soldOutImage")
          return ["Sold out"];
      },
    }
  },
};

var Helper = {
  get: function (url, context) {
    if (! url) {
      return null;
    } else if (url.search(/^https?:\/\/www\.amazon\.fr/) !== -1) {
      return AmazonFrHelper[context];
    } else if (url.search(/^https?:\/\/www\.rueducommerce\.fr/) !== -1) {
      return RueducommerceHelper[context];
    } else if (url.search(/^https?:\/\/www\.luisaviaroma\.com/) !== -1) {
      return LuisaviaromaHelper[context];
    } else if (url.search(/^https?:\/\/www\.brandalley\.fr/) !== -1) {
      return BrandalleyHelper[context];
    } else if (url.search(/^https?:\/\/[\w-]+\.placedestendances\.com/) !== -1) {
      return PlacedestendancesHelper[context];
    } else if (url.search(/^https?:\/\/[\w-]+\.spartoo\.com/) !== -1) {
      return SpartooHelper[context];
    } else if (url.search(/^https?:\/\/www\.zara\.com/) !== -1) {
      return ZaraHelper[context];
    } else if (url.search(/^https?:\/\/www\.shopbop\.com/) !== -1) {
      return ShopbopHelper[context];
    }
  }
};

return Helper;

});
