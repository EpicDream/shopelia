// FakeSaturn used for tests.
// Author : Vincent Renaudineau
// Created at : 2013-09-19

define(['src/saturn', 'mapping'], function(Saturn, Mapping) {
"use strict";

var FakeSaturn = function() {
  Saturn.apply(this, arguments);
  this.results = {};
  this.currentValue = {};
  this.urlCpt = 0;
  this._productToExtract = [];
  this.fakeUrls = [
    'http://www.mydomain.com/',
    'http://www.mydomain.com/path/to/the/file.html',
    'http://www.mydomain.com/path/to/the/file',
    'https://www.mydomain.com/',
    'https://www.mydomain.com/path/to/the/file.html',
    'https://www.mydomain.com/path/to/the/file',
  ];
};

FakeSaturn.prototype = new Saturn();


FakeSaturn.prototype.getFakeProduct = function() {
  if (Math.random() < 0.5)
    return [];
  else
    return [{id: this.urlCpt, url: this.fakeUrls[(this.urlCpt++) % this.fakeUrls.length]}];
};

//
FakeSaturn.prototype.loadProductUrlsToExtract = function(doneCallback, failCallback) {
  doneCallback(this._productToExtract.splice(0));
};

// GET mapping for url's host,
// and return jqXHR object.
FakeSaturn.prototype.loadMapping = function(merchantId) {
  return {
    done: function (fct) {
      if (merchantId === 2)
        fct(new Mapping({
          "id":2,
          "domain":"amazon.fr",
          "mapping":{
            "amazon.fr":{
              "availability":{"paths":["div.buying > *[class*=\"avail\"]","#secondaryUsedAndNew a.buyAction[href*='condition=used']"]},
              "description":{"paths":["#productDescription div.content, #ps-content div.content","#feature-bullets-atf .content, .techD:first .content, #artistCentralTeaser > div","#technical-specs_feature_div .content, .content .tsTable","#technicalProductFeaturesATF","div.bucket h2:contains(\"Description\") + div.content"]},
              "image_url":{"paths":["#main-image, #prodImage, #original-main-image"]},
              "name":{"paths":["span#btAsinTitle"]},
              "price":{"paths":["span#actualPriceValue b, span#buyingPriceValue b","#secondaryUsedAndNew a:not([href*=\"condition=used\"]) + .price"]},
              "price_strikeout":{"paths":["span#listPriceValue"]},
              "shipping_info":{"paths":["div.buying > *[class*=\"avail\"]","#secondaryUsedAndNew a.buyAction[href*='condition=used']"]},
              "price_shipping":{"paths":["#actualPriceExtraMessaging, #pricePlusShippingQty .plusShippingText","table.qpDivTop div.cBox table td:first"]},
              "option1":{"paths":[".variations div#selected_color_name + div .swatchSelect, .variations div#selected_color_name + div .swatchAvailable, .variations div#selected_color_name + div .swatchUnavailable","select#dropdown_selected_color_name"]},
              "option2":{"paths":["#dropdown_selected_size_name option.dropdownAvailable, #dropdown_selected_size_name option.dropdownSelect, div.buying > select#asinRedirect",".variations div.variationSelected[id!=selected_color_name] + div.spacediv .swatchSelect, .variations div.variationSelected[id!=selected_color_name] + div.spacediv .swatchAvailable, .variations div.variationSelected[id!=selected_color_name] + div.spacediv .swatchUnavailable"]},
            }
          }
        }));
      return this;
    },
    fail: function (fct) {
      if (merchantId !== 2)
        fct('unsupported');
      return this;
    }
  };
};

return FakeSaturn;
 
});
