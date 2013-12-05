//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-25

define(['logger', 'jquery', 'uri', 'crawler', 'core_extensions'], function(logger, $, Uri, Crawler) {
  "use strict";

  var map = {};
  
  map.SHOPELIA_DOMAIN = "https://www.shopelia.com";
  map.MAPPING_URL = map.SHOPELIA_DOMAIN + "/api/viking/mappings";
  map.MERCHANT_URL = map.SHOPELIA_DOMAIN + "/api/viking/merchants";

  map.FIELDS = [
    'name', 'brand', 'description', 'price', 'price_strikeout', 'price_shipping', 'shipping_info', 'availability', 'image_url', 'images', 'rating'
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
      query, toInt, url;
    if (typeof merchant === 'string') {
      toInt = parseInt(merchant, 10);
      if (toInt)
        query = '?merchant_id='+toInt;
      else
        query = "?url="+(url = merchant);
    } else if (typeof merchant === 'number') {
      query = '?merchant_id='+merchant;
    } else if (typeof merchant === 'object' && merchant.id) {
      query = '/'+merchant.id;
    } else if (typeof merchant === 'object' && merchant.merchant_id) {
      query = '?merchant_id='+merchant.merchant_id;
    } else if (typeof merchant === 'object' && merchant.url) {
      query = '?url='+merchant.url;
      url = merchant.url;
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
      deferred.resolve(new Mapping(hash, url));
    }).fail(function(err) {
      logger.error("Fail to retrieve mapping for merchantId "+merchant, err);
      deferred.reject(err);
    });
    return deferred;
  };

  map.save = function (mapping, id, url) {
    var deferred = new $.Deferred();

    if (typeof mapping === 'object') {
      id = mapping.id;
      mapping = JSON.stringify(mapping);
    } else if (typeof mapping !== 'string')
      throw "Cannot save mapping #"+id+". Wait an Mapping or an object, got a "+(typeof mapping);

    $.ajax({
      type : id !== undefined ? "PUT" : "POST",
      tryCount: 0,
      retryLimit: 5,
      url: map.MAPPING_URL + (id !== undefined ? '/'+id : ''),
      contentType: 'application/json',
      data: mapping
    }).done(function (res) {
      if (id === undefined)
        map.mapMappingToMerchant(url, res.id);
      deferred.resolve(id || res.id);
    }).fail(function (xhr, textStatus, errorThrown) {
      if (textStatus === 'timeout' || xhr.status === 502) {
        setTimeout(function () {
          $.ajax(this);
        }.bind(this), 2000);
      } else if (xhr.status == 500 && this.tryCount < this.retryLimit) {
        this.tryCount++;
        setTimeout(function () {
          $.ajax(this);
        }.bind(this), 2000);
      } else if (xhr.status == 413) {
        logger.warn("Mapping is too large to be sended by html. Remove pages.");
        var map = JSON.parse(mapping);
        delete map.data.pages;
        this.data = JSON.stringify(map);
        $.ajax(this);
      } else {
        deferred.reject();
      }
    });

    return deferred;
  };

  map.mapMappingToMerchant = function (url, mapping_id) {
    map.getMerchantFromUrl(url).done(function (hash) {
      $.ajax({
        type : "PUT",
        url: map.MERCHANT_URL + '/'+ hash.id,
        contentType: 'application/json',
        data: JSON.stringify({mapping_id: mapping_id}),
      }).fail(function (xhr, textStatus, errorThrown) {
        logger.warn("Fail to update mapping_id of merchant #"+(hash.id)+" to "+mapping_id+".");
      });
    }).fail(function(err) {
      logger.err("Fail to find merchant with url="+(url)+".");
    });
  };


  map.getMerchantFromUrl = function (url) {
    return $.ajax({
      type : "GET",
      dataType: "json",
      url: map.MERCHANT_URL + '?url=' + url,
    }).fail(function (xhr, textStatus, errorThrown) {
      logger.warn("Fail to retrieve merchant from url '"+url+"'.");
    });
  };

  map.getMerchants = function () {
    return $.ajax({
      type : "GET",
      dataType: "json",
      url: map.MERCHANT_URL,
    });
  };

  map.getMappings = function () {
    var deferred = new $.Deferred();

    $.ajax({
      type : "GET",
      dataType: "json",
      url: map.MAPPING_URL,
    }).done(function (array) {
      deferred.resolve(array.map(function (hash) {
        return new Mapping(hash);
      }));
    });

    return deferred;
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
    var res = $extend(true, mapping),
      field, i, paths;
    for (field in mapping) {
      paths = res[field].paths || [];
      for (i = 0; i < paths.length; i++)
        paths[i].replace(/:visible/g,'');
    }
    return mapping;
  };

  var Mapping = function (map, url) {
    $extend(this, map);
    this._pages = {};
    if (this.pages)
      for (var i = 0; i < this.pages.length; i++) {
        var page = this.pages[i];
        this._pages[page.url] = page;
      }

    if (! this.mapping)
      this._initMerchantData(url);

    if (this.mapping["default"])// Choose default first
      this.setHost("default");
    else if (url)// url domain then,
      this.setUrl(url);
    else// mapping domain at end.
      this.setHost(this.domain);
    
    this._$ = $;
    this._origin = document;
  };

  Mapping.prototype = {};

  Mapping.prototype.toJSON = function() {
    return JSON.stringify(this.toObject());
  };

  Mapping.prototype.toObject = function() {
    return {id: this.id, domain: this.domain, url: this.url, mapping: $extend(true, this.mapping)}; // , pages: this._pages.values()
  };

  Mapping.prototype.save = function () {
    return map.save(this, this.id, this.url);
  };

  //TODO: handle frameworks like prestashop, magento, shopify, etc
  Mapping.prototype._initMerchantData = function (url) {
    var i;
    this.host = 'default';
    this.domain = map.getMinHost(url);
    this.mapping = {};
    this.mapping['default'] = {};
    for (i = map.FIELDS.length - 1 ; i >= 0 ; i--)
      this.mapping['default'][map.FIELDS[i]] = {paths: []};
  };

  // Build a single host agnostic mapping by merging different host mapping.
  //TODO: Better handle frameworks/ref/default mapping.
  Mapping.prototype._buildMapping = function (host) {
    host = host || this.host;
    var result = {};
    logger.debug("Going to build a mapping for host", host, "between", $.map(this.mapping,function(v, k){return k;}) );
    while (host !== "") {
      if (this.mapping[host])
        result = $.extend(false, {}, this.mapping[host], result);
      host = host.replace(/^[\w-]+(\.|$)/, '');
    }
    if (this.mapping["default"])
      result = $.extend(false, {}, this.mapping["default"], result);
    return result;
  };

  // Return compatible hosts in mapping for given host.
  // Result contains at least one host, the host given in argument.
  Mapping.prototype._compatibleHosts = function () {
    var host = this.host,
      result = [host];
    host = host.replace(/^[\w-]+(\.|$)/, '');
    while (host !== "") {
      if (this.mapping[host])
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
    this.host = host || "default";
    if (! this.mapping[this.host])
      this.mapping[this.host] = {};
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
    if (! this.mapping[host])
      this.mapping[host] = {};
    mapping = this.mapping[host];
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
    logger.debug("Going to crawl in a "+Object.keys(mapping).length+" fields mapping with host="+host+".");
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
        if (oldResults[field] != newResults[field] && (''+oldResults[field]) != (''+newResults[field])) {
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