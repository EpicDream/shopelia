// FakeSaturn used for tests.
// Author : Vincent Renaudineau
// Created at : 2013-09-19

(function() {
"use strict";

var FakeSaturn = function() {
  Saturn.apply(this, arguments);
  this.TEST_ENV = false;
  this.results = {};
  this.currentValue = {};
  this.tabCpt = 0;
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

FakeSaturn.prototype.openNewTab = function() {
  this.tabs.nbUpdating++;
  return Saturn.prototype.openNewTab.call(this, this.tabCpt++);
};

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
FakeSaturn.prototype.loadMapping = function(merchantId, doneCallback, failCallback) {
  if (merchantId === 2)
    doneCallback({
      "id":2,
      "data":{
        "viking":{
          "amazon.fr":{
            "availability":{"path":["div.buying > *[class*=\"avail\"]","#secondaryUsedAndNew a.buyAction[href*='condition=used']"]},
            "description":{"path":["#productDescription div.content, #ps-content div.content","#feature-bullets-atf .content, .techD:first .content, #artistCentralTeaser > div","#technical-specs_feature_div .content, .content .tsTable","#technicalProductFeaturesATF","div.bucket h2:contains(\"Description\") + div.content"]},
            "image_url":{"path":"#main-image, #prodImage, #original-main-image"},
            "name":{"path":"span#btAsinTitle"},
            "price":{"path":["span#actualPriceValue b, span#buyingPriceValue b","#secondaryUsedAndNew a:not([href*=\"condition=used\"]) + .price"]},
            "price_strikeout":{"path":"span#listPriceValue"},
            "shipping_info":{"path":["div.buying > *[class*=\"avail\"]","#secondaryUsedAndNew a.buyAction[href*='condition=used']"]},
            "price_shipping":{"path":["#actualPriceExtraMessaging, #pricePlusShippingQty .plusShippingText","table.qpDivTop div.cBox table td:first"],"default_value":"GRATUIT sans minimum d achat pour les livres, les chaussures et les vêtements.\nGRATUIT à partir de 15 EUR d achats pour les autres produits, ou 2,79 EUR par envoi en dessous de 15 EUR d achat."},
            "sizes":{"path":["#dropdown_selected_size_name option.dropdownAvailable, #dropdown_selected_size_name option.dropdownSelect, div.buying > select#asinRedirect",".variations div.variationSelected[id!=selected_color_name] + div.spacediv .swatchSelect, .variations div.variationSelected[id!=selected_color_name] + div.spacediv .swatchAvailable, .variations div.variationSelected[id!=selected_color_name] + div.spacediv .swatchUnavailable"]},
            "colors":{"path":[".variations div#selected_color_name + div .swatchSelect, .variations div#selected_color_name + div .swatchAvailable, .variations div#selected_color_name + div .swatchUnavailable","select#dropdown_selected_color_name"]}
          }
        }
      }
    });
  else
    failCallback('unsupported');
};

// 
FakeSaturn.prototype.openUrl = function(session, url) {
  session.then();
};

// 
FakeSaturn.prototype.evalAndThen = function(session, cmd, callback) {
  var result;
  switch (cmd.action) {
    case "getOptions" :
      switch (cmd.option) {
        case 1:
          result = [{text: 'color1'}, {text: 'color2'}];
          break;
        case 2:
          result = [{text: 'size1'}, {text: 'size2'}];
          break;
        default:
          result = [{text: 'option'+cmd.option+'1'}, {text: 'option-'+cmd.option+'-2'}];
      }
      break;
    case 'setOption' :
      this.currentOption = cmd.option;
      this.currentValue[cmd.option] = cmd.value;
      break;
    case 'crawl' :
      result = {title: "Le titre de mon produit."};
      break;
    default:
      throw "Bad command action : "+cmd.action;
  }
  if (callback)
    callback(result);
  else
    session.then();
};


if ("object" == typeof module && module && "object" == typeof module.exports)
  exports = module.exports = FakeSaturn;
else if ("function" == typeof define && define.amd)
  define("fake_saturn", ["saturn"], function(){return FakeSaturn;});
else
  window.FakeSaturn = FakeSaturn;
 
})();
