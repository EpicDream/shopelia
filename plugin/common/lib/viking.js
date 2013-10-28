//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-25

define(['logger', 'jquery', 'uri'], function(logger, $, Uri) {
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

  // Merge new mapping in the previous one.
  // Try to know if a mapping must be added before (it is more specific)
  // or after (it is less specific) existing ones.
  viking.merge = function(currentMap, data, host) {
    // GOING TO MERGE NEW MAPPING WITH OLD ONES
    // create new host rule if it did not exist.
    logger.debug('Going to merge', currentMap, 'in', data.viking);

    //
    var possibleHosts = viking.compatibleHosts(host, data);

    for (var key in currentMap) {
      // if no new map, continue
      if (! currentMap[key])
        continue;

      // On choisit le bon host, général ou spécific.
      var goodHost;
      if (possibleHosts.length > 1) {
        goodHost = prompt("Pour quel host ce chemin est-il valide ?\n"+possibleHosts.join("\n"));
        if (! goodHost) {
          logger.warn("key '"+key+"' with new path '"+newPath+"' skiped.");
          continue;
        }
      } else
        goodHost = possibleHosts[0];

      // On initialize la structure si elle n'existant pas.
      if (! data.viking[goodHost])
        data.viking[goodHost] = {};
      var mapping = data.viking[goodHost];
      if (! mapping[key]) mapping[key] = {path: []};
      if (! mapping[key].path) mapping[key].path = [];

      var newPath = currentMap[key].path;
      var oldPath = mapping[key].path;
      logger.debug('Merge for key "'+key+'", "'+newPath+'" in "'+oldPath+'"');

      // if it did not exist, just create it and continue.
      if (! oldPath) {
        mapping[key] = {path: [newPath]};
        continue;
      }
      // if old version, update it.
      if (! (oldPath instanceof Array)) {
        mapping[key] = {path: [oldPath]};
        oldPath = mapping[key].path;
      }
      // if already contains it, pass
      if (oldPath.filter(function(e) {return e.indexOf(newPath) !== -1;}).length > 0) {
        logger.debug(oldPath, "already contains", newPath);
        continue;
      }

      var newMatch = $(newPath);
      for (var i = 0, l = oldPath.length ; i < l ; i++) {

        var str = "Pour le nouveau path \""+newPath+"\",\n" + "et l'ancien path \""+oldPath[i]+"\",\n",
            previousMatch = $(oldPath[i]);
        if (previousMatch.length == newMatch.length && $.makeArray(previousMatch) == $.makeArray(newMatch)) {
          alert(str + "les mêmes éléments sont capturés.");
        } else
          alert(str + previousMatch.length + " éléments étaient capturés avant, " + newMatch.length + " maintenant.");

        if (confirm(str + "concaténer les paths ?")) {
          oldPath[i] += ", "+newPath;
          break;
        } else if (confirm(str + "remplacer le path ?")) {
          oldPath.splice(i,1,newPath);
          break;
        } else if (confirm(str + "Le placer juste avant ?" + (i > 0 ? "\nPrécédent : \""+oldPath[i-1]+"\"." : ''))) {
          oldPath.splice(i,0,newPath);
          break;
        } else if (confirm(str + "Le placer juste après ?" + (i < l-1 ? "\nSuivant : \""+oldPath[i+1]+"\"." : ''))) {
          oldPath.splice(i+1,0,newPath);
          break;
        } else if (i < l-1 && confirm("Reposer les questions pour ce path ?")) {
          i = i-1;
          continue;
        } else if (i < l-1 && ! confirm("Passer au path suivant ? (sinon on annule)")) {
          break;
        }
      }
      // Par défaut on rajoute à la suite
      if (i == l) {
        if (l > 0)
          alert("On ajoute ce path à la suite des autres.");
        oldPath.push(newPath);
      }
    }
  };

  // Return the doc (default to current document) has a viking's page.
  viking.getPage = function (doc) {
    doc = doc || document;
    return {
      innerHTML: doc.documentElement.innerHTML,
      title: doc.title,
      href: document.location.href,
    };
  };

  // Get the DOMDocument from the viking's saved page.
  viking.getDocument = function (page) {
    var doc = document.implementation.createHTMLDocument(page.title);
    doc.documentElement.innerHTML = page.innerHTML;
    return doc;
  };

  return viking;
});
