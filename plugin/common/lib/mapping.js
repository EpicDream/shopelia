//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-25

define(['logger', 'jquery', 'uri', 'crawler', 'core_extensions'], function(logger, $, Uri, Crawler) {
  "use strict";

  var map = {};
  
  map.SHOPELIA_DOMAIN = "https://www.shopelia.fr";
  map.MAPPING_URL = map.SHOPELIA_DOMAIN + "/api/viking/merchants";

  map.FIELDS = [
    'name', 'brand', 'description', 'price', 'price_strikeout', 'price_shipping', 'shipping_info', 'availability', 'image_url', 'images'
  ];
  map.MANDATORY_FIELDS = [
    'name', 'price', 'price_shipping', 'availability'
  ];
  map.OPTIONAL_FIELDS = [
    'brand', 'description', 'price_strikeout', 'shipping_info', 'image_url', 'images'
  ];
  map.HTML_FIELDS = [
    'description'
  ];
  map.TEXT_FIELDS = [
    'name', 'brand', 'description', 'price', 'price_strikeout', 'price_shipping', 'shipping_info', 'availability'
  ];
  map.IMAGE_FIELDS = [
    'image_url', 'images'
  ];

  // http://video.fnac.fr/mon_produit/dp/00000000
  // => video.fnac.fr
  // http://www.amazon.fr/mon_produit/dp/00000000
  // => amazon.fr
  map.getHost = function (url) {
    var host = (new Uri(url)).host();
    if (host.search(/^www\./) !== -1)
      host = host.slice(4);
    return host;
  };

  // http://video.fnac.fr/mon_produit/dp/00000000
  // => fnac.fr
  map.getMinHost = function (url) {
    var host = map.getHost(url);
    // Tant qu'on un mot de 5 lettres ou plus après et qu'il n'est pas le dernier, on supprime le sous domaine.
    while (host.search(/[\w-]+\.[\w-]{4,}\.[\w-]+/) !== -1)
      host = host.slice(host.indexOf('.')+1);
    return host;
  };

  // GET mapping for merchant.
  // Return a jqXHR object. See jQuery.Deferred().
  map.load = function(merchant) {
    var deferred = new $.Deferred(),
      query, toInt;
    if (typeof merchant === 'string') {
      toInt = parseInt(merchant, 10);
      if (toInt)
        query = '/'+toInt;
      else
        query = "?url="+merchant;
    } else if (typeof merchant === 'number') {
      query = '/'+merchant;
    } else {
      logger.error("`Mapping.load' ArgumentError : Wait a string or a number, got a "+(typeof merchant));
      return deferred.reject("ArgumentError");
    }
    logger.debug("Going to get mapping for merchant '"+merchant+"'");
    $.ajax({
      type : "GET",
      dataType: "json",
      url: map.MAPPING_URL+query,
    }).done(function (hash) {
      if (hash.data && hash.data.ref) {
        map.load(hash.data.ref).done(function(mapp) {
          mapp.refs.unshift(mapp.id);
          mapp.id = hash.id;
          if (typeof merchant === 'string' && ! toInt)
            mapp.setUrl(merchant);
          deferred.resolve(mapp);
        }).fail(function(err) {
          logger.error("Fail to retrieve mapping for merchantId "+merchant, err);
          deferred.reject(err);
        });
      } else
        deferred.resolve(new Mapping(hash, typeof merchant === 'string' && ! toInt ? merchant : undefined));
    }).fail(function(err) {
      logger.error("Fail to retrieve mapping for merchantId "+merchant, err);
      deferred.reject(err);
    });
    return deferred;
  };

  map.getMerchants = function () {
    return $.ajax({
      type : "GET",
      dataType: "json",
      url: map.MAPPING_URL,
    });
  };

  // Return the doc (default to current document) has a viking's page.
  map.doc2page = function (doc) {
    doc = doc || document;
    return {
      innerHTML: doc.documentElement.innerHTML,
      title: doc.title,
      url: document.location.href,
    };
  };

  // Get the DOMDocument from the viking's saved page.
  map.page2doc = function (page) {
    var doc = document.implementation.createHTMLDocument(page.title);
    doc.documentElement.innerHTML = page.innerHTML;
    doc.title = page.title;
    return doc;
  };

  // Mapping must be adapt to be used for search in a page.
  map.adaptMapping= function (mapping) {
    var field, i, paths, path;
    for (field in mapping) {
      paths = mapping[field].paths || [];
      for (i = 0; i < paths.length; i++) {
        path = paths[i];
        if (path.search(/:visible/) !== -1)
          paths.push(path.replace(/:visible/,''));
      }
    }
    return mapping;
  };

  var Mapping = function (merchant, url) {
    this._data = merchant.data || {};
    this.id = merchant.id;
    this.url = url;
    this.refs = [];
    this._pages = this._data.pages || {};

    if (this._data.viking)
      this._host_mappings = this._data.viking;
    else
      this._initMerchantData(url);

    if (this._host_mappings["default"])
      this.setHost("default");
    else if (url)
      this.setUrl(url);
    
    this._$ = $;
    this._origin = document;
  };

  Mapping.prototype = {};

  Mapping.prototype.toObject = function() {
    return {id: this.id, data: {viking: this._host_mappings, pages: this._pages}};
  };

  //TODO: handle frameworks like prestashop, magento, shopify, etc
  Mapping.prototype._initMerchantData = function (url) {
    var i;
    this.host = 'default';
    this._data = this._data || {};
    this._host_mappings = {};
    this._host_mappings['default'] = {};
    for (i = map.FIELDS.length - 1 ; i >= 0 ; i--)
      this._host_mappings['default'][map.FIELDS[i]] = {paths: []};
  };

  // Build a single host agnostic mapping by merging different host mapping.
  //TODO: Better handle frameworks/ref/default mapping.
  Mapping.prototype._buildMapping = function (host) {
    host = host || this.host;
    var mappings = this._host_mappings,
      result = {};
    logger.debug("Going to build a mapping for host", host, "between", $.map(mappings,function(v, k){return k;}) );
    while (host !== "") {
      if (mappings[host])
        result = $.extend(false, {}, mappings[host], result);
      host = host.replace(/^[\w-]+(\.|$)/, '');
    }
    if (mappings["default"])
      result = $.extend(false, {}, mappings["default"], result);
    return result;
  };

  // Return compatible hosts in mapping for given host.
  // Result contains at least one host, the host given in argument.
  Mapping.prototype._compatibleHosts = function () {
    var host = this.host,
      mappings = this._host_mappings,
      result = [host];
    host = host.replace(/^[\w-]+(\.|$)/, '');
    while (host !== "") {
      if (mappings[host])
        result.push(host);
      host = host.replace(/^[\w-]+(\.|$)/, '');
    }
    return result;
  };

  Mapping.prototype.setUrl = function (url) {
    this.url = url;
    this.setHost(map.getHost(url));
  };

  Mapping.prototype.setHost = function (host) {
    this.host = host;
    if (this._host_mappings["default"] !== undefined)
      this.host = "default";
    else if (! this._host_mappings[this.host])
      this._host_mappings[this.host] = {};
    this.compatibleHosts = this._compatibleHosts();
    this.currentMap = this._buildMapping();
  };

  Mapping.prototype.get = function (field) {
    return this.currentMap[field];
  };

  Mapping.prototype.addPath = function (field, newPath, host) {
    var mapping, oldPath, i, str, previousMatch;

    logger.debug("Going to add '" + newPath + "' in field '" + field + "'.");
    host = host || this.host;

    // On initialize la structure si elle n'existant pas.
    if (! this._host_mappings[host])
      this._host_mappings[host] = {};
    mapping = this._host_mappings[host];
    if (! mapping[field]) mapping[field] = {paths: []};
    if (! mapping[field].paths) mapping[field].paths = [];

    oldPath = mapping[field].paths;
    logger.debug('Merge for field "'+field+'", "'+newPath+'" in "'+oldPath+'"');

    // if it did not exist, just create it and continue.
    if (oldPath.length === 0) {
      oldPath.push(newPath);
    // if already contains it, pass
    } else if (oldPath.filter(function(e) {return e.indexOf(new RegExp("(^|,\\s*)"+newPath+"(,|$)")) !== -1;}).length > 0) {
      logger.warn(oldPath, "already contains", newPath);
    } else {
      newMatch = this.search(newPath);
      for (i = 0, l = oldPath.length ; i < l ; i++) {
        str = "Pour le nouveau path \""+newPath+"\",\n" + "et l'ancien path \""+oldPath[i]+"\",\n";
        previousMatch = this.search(oldPath[i]);
        if (previousMatch.length == newMatch.length && previousMatch.toArray() == newMatch.toArray()) {
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
        } else if (i == l-1 && confirm("Reprendre depuis le début ? (sinon on annule)")) {
          i = -1;
        }
      }
    }
    this.currentMap = this._buildMapping();
    return oldPath.slice(0);
  };

  Mapping.prototype.chooseHost = function () {
    // On choisit le bon host, général ou spécific.
    var goodHost, possibleHosts, str, goodHostNb;
    if (this.compatibleHosts.length === 1)
      return this.compatibleHosts[0];

    possibleHosts = this.compatibleHosts.map(function(host,i) {return (i+1) + ") " + host;}).join("\n");
    str = "Pour quel host ce chemin est-il valide ?\n"+possibleHosts;
    goodHost = prompt(str);
    while (goodHost !== null) {
      idx = this.compatibleHosts.indexOf(goodHost.trim());
      if (idx !== -1)
        return goodHost;
      idx = parseInt(goodHost, 10);
      if (idx >= 1)
        return this.compatibleHosts[goodHostNb-1];
      goodHost = prompt("Réponse incorrect : '"+goodHost+"'.\n" + str);
    }
    return goodHost;
  };

  Mapping.prototype.search = function(path) {
    return this._$(path, this._origin);
  };

  Mapping.prototype.saveCurrentPage = function() {
    var page = map.doc2page();
    this._pages[location.href] = page;
    this._pages[location.href].results = this.crawlPage(page);
  };

  Mapping.prototype.setPage = function(page, url) {
    url = url || page.url;
    this._pages[url] = page;
  };
  
  Mapping.prototype.updatePage = function(page, url) {
    this.setPage(page, url);
  };

  Mapping.prototype.getPage = function(url) {
    return this._pages[url];
  };

  Mapping.prototype.crawlPage = function (page) {
    var pageDoc = Mapping.page2doc(page),
      host = map.getHost(page.url || page.href),
      mapping = this._buildMapping(host);
    logger.debug("Going to crawl in a "+Object.keys(mapping).length+" fields mapping with host="+host+".", mapping.availability.paths.join());
    return Crawler.fastCrawl(map.adaptMapping(mapping), pageDoc);
  };

  Mapping.prototype.checkConsistency = function (field) {
    var pages = this._pages,
      url = this.url,
      results = {},
      page, pageUrl, mapping, fields, oldResults, pageDoc, newResults, i;

    for (pageUrl in pages) {
      logger.debug("Going to check consistency for "+pageUrl);
      if (pageUrl === url) continue;
      page = pages[pageUrl];
      oldResults = page.results;
      if (! oldResults) continue;
      // console.debug($.map(oldResults, function(v,k) {return "'"+k+"':'"+v.slice(0,80)+"'";}).join());
      fields = field ? [field] : Object.keys(oldResults);
      if (! page.url && ! page.href) page.url = pageUrl;
      newResults = this.crawlPage(page);
      logger.debug($.map(newResults, function(v,k) {return ("'"+k+"':'"+v+"'").slice(0,100);}).join());
      for (i = fields.length - 1; i >= 0; i--) {
        field = fields[i];
        logger.debug("Check consistency for field "+field);
        if (oldResults[field] != newResults[field]) {
          logger.warn("ERROR on field '"+field+"' : old '" + oldResults[field] + "' != new '" + newResults[field] + "', ", Object.keys(newResults).join());
          results[field] = results[field] || [];
          results[field].push({
            url: page.url,
            old: oldResults[field],
            new: newResults[field],
            msg: "On page '"+page.url+"',\n'" + newResults[field] + "' got, but\n'" + oldResults[field] + "' waited.",
          });
        }
      }
    }
    return results;
  };

  $extend(Mapping, map);

  return Mapping;
});