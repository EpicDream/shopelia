//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-25

define("viking", ['logger', 'jquery'], function(logger, $) {
  "use strict";

  var viking = {};
  
  viking.SHOPELIA_DOMAIN = "https://www.shopelia.fr";
  viking.MAPPING_URL = viking.SHOPELIA_DOMAIN + "/api/viking/merchants";

  viking.MAPPING_FIELDS = [
    'name', 'brand', 'description', 'price', 'price_strikeout', 'price_shipping', 'shipping_info', 'availability', 'image_url', 'images'
  ];
  viking.MANDATORY_FIELDS = [
    'name', 'price', 'price_shipping', 'availability'
  ];
  viking.OPTIONAL_FIELDS = [
    'brand', 'description', 'price_strikeout', 'shipping_info', 'image_url', 'images'
  ];
  viking.TEXT_FIELDS = [
    'name', 'brand', 'description', 'price', 'price_strikeout', 'price_shipping', 'shipping_info', 'availability'
  ];
  viking.IMAGE_FIELDS = [
    'image_url', 'images'
  ];

  // GET mapping for merchantId.
  // Return a jqXHR object. See jQuery.Deferred().
  viking.loadMapping = function(merchantId, doneCallback, failCallback) {
    if (typeof merchantId === 'string') {
      var toInt = parseInt(merchantId, 10);
      if (toInt)
        merchantId = '/'+toInt;
      else
        merchantId = "?url="+merchantId;
    }
    logger.debug("Going to get mapping for merchantId '"+merchantId+"'");
    var deferred = $.ajax({
      type : "GET",
      dataType: "json",
      url: viking.MAPPING_URL+merchantId,
    }).done(doneCallback).fail(failCallback || function(err) {
      logger.error("Fail to retrieve mapping for merchantId "+merchantId, err);
    });
  };

  // http://www.amazon.fr/mon_produit/dp/00000000
  // => www.amazon.fr
  viking.getHost = function(url) {
    var host = (new Uri(url)).host();
    if (host.search(/^www\./) !== -1)
      host = host.slice(4);
    return host;
  };

  // http://www.amazon.fr/mon_produit/dp/00000000
  // => amazon.fr
  viking.getMinHost = function(url) {
    var host = viking.getHost(url);
    // Tant qu'on un mot de 5 lettres ou plus après et qu'il n'est pas le dernier, on supprime le sous domaine.
    while (host.search(/[\w-]+\.[\w-]{5,}\.[\w-]+/) !== -1)
      host = host.slice(host.indexOf('.')+1);
    return host;
  };

  viking.initMerchantData = function(url) {
    var i, data = {viking: {}},
        host = viking.getMinHost(url);
    data.viking[host] = {};
    for (i = viking.MAPPING_FIELDS.length - 1 ; i >= 0 ; i--)
      data.viking[host][viking.MAPPING_FIELDS[i]] = {path: []};
    return data;
  };

  // Build a single host agnostic mapping by merging different host mapping.
  viking.buildMapping = function(url, data) {
    var host = viking.getHost(url),
        mappings = data.viking,
        resMapping = {};
    console.log("Going to search a mapping for host", host, "between", $.map(mappings,function(v, k){return k;}) );
    while (host !== "") {
      if (mappings[host])
        resMapping = $.extend(true, {}, mappings[host], resMapping);
      host = host.replace(/^[\w-]+(\.|$)/, '');
    }
    return resMapping;
  };

  // Return compatible hosts in mapping for given host.
  // Result contains at least one host, the host given in argument.
  viking.compatibleHosts = function(host, mapping) {
    var result = [host];
    host = host.replace(/^[\w-]+(\.|$)/, '');
    while (host !== "") {
      if (mapping.viking[host])
        result.push(host);
      host = host.replace(/^[\w-]+(\.|$)/, '');
    }
    return result;
  };

  return viking;
});
