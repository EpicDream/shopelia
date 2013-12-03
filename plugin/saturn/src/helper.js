// Saturn Merchant Helper
// Author : Vincent Renaudineau
// Created at : 2013-09-05

define(['logger', 'core_extensions'], function(logger) {

"use strict";

var helper = {};

helper.help = function (session) {
  if (session.url.search(/^https?:\/\/www\.priceminister\.com/) !== -1) {
    this.priceminister.help(session);
  } else if (session.url.search(/^https?:\/\/www\.rueducommerce\.fr/) !== -1) {
    this.rueducommerce.help(session);
  } else if (session.url.search(/^https?:\/\/www\.luisaviaroma\.com/) !== -1) {
    this.luisaviaroma.help(session);
  }
};

helper.priceminister = {};

helper.priceminister.help = function (session) {
  session.helper = this;
  session.helpersData = {};
  session.helpersData.oldUrl = session.url;
  session.url = this.preProcessUrl(session.url);
  session.helpersData.oldOnNextStep = session.then;
  session.then = this.onNextStep;
};

helper.priceminister.preProcessUrl = function (url) {
  if (url.search(/filter=10/) !== -1)
    return url;
  if (url.search(/filter=\d0/) !== -1) {
    url = url.replace(/filter=\d0/, 'filter=10');
  } else
    url += (url.search(/#/) !== -1 ? "&filter=10" : "#filter=10");
  return url;
};

helper.priceminister.onNextStep = function () {
  var that = this;
  chrome.tabs.get(this.tabId, function(tab) {
    var newUrl = that.helper.preProcessUrl(tab.url);
    if (newUrl === tab.url)
      that.helpersData.oldOnNextStep.apply(that);
    else
      that.saturn.openUrl(that, newUrl);
  });
};

helper.rueducommerce = {};

helper.rueducommerce.help = function (session) {
  session.helper = this;
};

helper.rueducommerce.before_crawling = function(callback) {
  setTimeout(callback, 1000);
};

helper.luisaviaroma = {};

helper.luisaviaroma.help = function (session) {
  session.helper = this;
};

helper.luisaviaroma.before_crawling = function(callback) {
  setTimeout(callback, 1000);
};

return helper;

});

/*
On remplace le then,
Dans le then on vérifie qu'il y a bien filter=10, sinon, on rajoute, et on recharge.
Comment vérifier qu'il y a bien le filter=10 ?
chrome.query ?
*/