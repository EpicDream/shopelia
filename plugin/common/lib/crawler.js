// Saturn Crawler.
// Author : Vincent Renaudineau
// Created at : 2013-09-20

define(["logger", "jquery", "html_utils", "helper", "core_extensions"], function(logger, $, hu, Helper) {
  "use strict";

var Crawler = function (url, doc) {
  var that = this;

  this.doc = doc || window.document;
  this.url = url || location.href;
  this.helper = Helper.get(this.url, 'crawler');

  this.onbeforeunloadBack = window.onbeforeunload;
  window.onbeforeunload = function () {
    that.pageWillBeUnloaded = true;
    if (typeof that.onbeforeunloadBack === 'function')
      return that.onbeforeunloadBack();
  };

  $(document).ready(this.onDocumentReady.bind(this));
};

Crawler.OPTION_FILTER = /^$|choi|choo|s(é|e)lect|toute|^\s*tailles?\s*$|^\s*couleurs?\s*$|Indisponible|non disponible|rupture de stock/i;
Crawler.DELAY_BETWEEN_OPTIONS = 1500;

Crawler.prototype.onDocumentReady = function () {
  if (this.helper && this.helper.atLoad) {
    this.helper.atLoad(this.goNextStep.bind(this));
  } else
    // To handle redirection, that throws false 'complete' state.
    setTimeout(this.goNextStep.bind(this), 100);
};

Crawler.prototype.goNextStep = function () {
  throw "Crawler.goNextStep is a virtual function MUST BE reimplemented.";
};

Crawler.prototype.waitAjax = function () {
  if (this.helper && this.helper.waitAjax) {
    this.helper.waitAjax(this.goNextStep.bind(this));
  } else if (! this.pageWillBeUnloaded)
    setTimeout(this.goNextStep.bind(this), Crawler.DELAY_BETWEEN_OPTIONS);
};

Crawler.prototype.doNext = function (hash) {
  logger.debug("ProductCrawl", hash.action, "task received", hash);
  key = "option"+hash.option;
  switch (hash.action) {
    case "getOptions":
      if (hash.mapping[key]) {
        result = this.getOptions(hash.mapping[key].paths);
      } else
        result = [];
      break;
    case "setOption":
      result = this.setOption(hash.mapping[key].paths, hash.value);
      break;
    case "crawl":
      result = this.crawl(hash.mapping);
      break;
    default:
      logger.error("Unknow command", hash.action);
      result = false;
  }
  // wait minimal to let page reload on url change
  if (hash.action === "setOption")
    setTimeout(this.waitAjax.bind(this), 1000);
  return result;
};

//
Crawler.prototype.searchImages = function (field, elems) {
  var res;

  if (field === 'images' && location.host.match("fnac.com")) {
    res = elems.filter("[style]").filter(function(i, e) {
      return $(this).css("background-image").search(/url\(.*\)/) !== -1;
    }).each(function() {
      var url = $(this).css("background-image").match(/url\((.*)\)/)[1];
      $(this).attr("src", url);
    });
  } else {
    res = elems.find("img").addBack("img").sort(function(i1, i2) {
      return (i2.height * i2.width) - (i1.height * i1.width);
    });
  }

  return res;
};

//
function searchImagesOptions(elems) {
  var size = elems.length,
    res;

  if (location.host.match("amazon.fr")) {
    res = elems.find(".swatchInnerImage[style]").filter(function(i, e) {
      return $(this).css("background-image").search(/url\(.*\)/) !== -1;
    }).each(function() {
      var url = $(this).css("background-image").match(/url\((.*)\)/)[1];
      $(this).parent().parent().attr("src", url);
    }).parent().parent();
  } else
    res = elems.find("img:visible").addBack("img:visible");

  if (res.length !== size)
    res = $();

  return res;
}

//
Crawler.prototype.searchOption = function (paths) {
  var elems, i, l, path, tmp_elems, nbOptions;

  if (! paths)
    return $();
  if (! (paths instanceof Array))
    throw "ArgumentError : was waiting an Array of String, and got a " + (typeof paths);

  for (i = 0, l = paths.length; i < l ; i++) {
    path = paths[i];
    elems = $(path, this.doc);
    if (elems.length === 0) {
      continue;
    // SELECT, le cas facile
    } else if (elems[0].tagName == "SELECT") {
      elems = elems.eq(0).find("option:enabled");
    } else {
      // UL, le cas pas trop compliqué
      if (elems[0].tagName == "UL")
        elems = elems.find("li:visible");
      // Maintenant, on part du principe que elems contient déjà toutes les options.
      nbOptions = elems.length;
      if (nbOptions === 0)
        continue;
      // on cherche si il y a des images
      tmp_elems = searchImagesOptions(elems);
      if (tmp_elems.length === nbOptions)
        elems = tmp_elems;
    }
    elems.saturnPath = path;
    break;
  }
  return elems || $();
};

//
Crawler.prototype.parseOption = function (elems) {
  return elems.toArray().filter(function(elem) {
    return elem.innerText.match(Crawler.OPTION_FILTER) === null || elem.src;
  }).map(function(elem) {
    var h = hu.getElementAttrs(elem);
    h.xpath = hu.getElementXPath(elem);
    h.cssPath = hu.getElementCSSSelectors($(elem));
    h.saturnPath = elems.saturnPath;
    matchBack = h.style && h.style.match(/background(\-color|\-image)? *: *(url\(([^\)]+)\)|#[A-F\d]{3,6}|\w+) *;/i);
    matchBack = matchBack && matchBack[0];
    h.hash = [h.id,h.text,h.value,h.src,h.href,matchBack].join(';');
    return h;
  });
};

// Return an array of option's value.
Crawler.prototype.getOptions = function (paths) {
  var elems = this.searchOption(paths);
  return this.parseOption(elems);
};

// Return a jQuery instance.
Crawler.prototype.selectOption = function (elems, value) {
  if (elems.length === 0)
    return $();

  var backup = elems;

  if (elems[0].tagName === "OPTION") {
    elems = elems.filter(':contains("'+value.text+'")');
    if (elems.length === 0) elems.end(); // undo last filter.
  }
  if (elems.length > 1 && elems[0].tagName === "OPTION") {
    elems = elems.filter("[value='"+value.value+"']");
    if (elems.length === 0) elems.end(); // undo last filter.
  }
  if (elems.length > 1 && value.id) {
    elems = elems.filter(function () {return this.id === value.id;});
    if (elems.length === 0) elems.end(); // undo last filter.
  }
  if (elems.length > 1 && value.text) {
    elems = elems.filter(':contains("'+value.text+'")');
    if (elems.length === 0) elems.end(); // undo last filter.
  }
  if (elems.length > 1 && value.src) {
    elems = elems.filter("[src='"+value.src+"']");
    if (elems.length === 0) elems.end(); // undo last filter.
  }
  if (elems.length > 1 && value.href) {
    elems = elems.filter("[href='"+value.href+"']");
    if (elems.length === 0) elems.end(); // undo last filter.
  }
  if (elems.length > 1 && value.value) {
    elems = elems.filter("[value='"+value.value+"']");
    if (elems.length === 0) elems.end(); // undo last filter.
  }
  if (elems.length > 1 && value.title) {
    elems = elems.filter("[title='"+value.title+"']");
    if (elems.length === 0) elems.end(); // undo last filter.
  }
  if (elems.length > 1 && value.style && value.style.search(/background/i) !== -1) {
    elems = elems.filter("[style='"+value.style+"']");
    if (elems.length === 0) elems.end(); // undo last filter.
  }

  return elems;
};

//
Crawler.prototype.setOption = function(paths, value) {
  var elems = this.searchOption(paths);
  elems = this.selectOption(elems, value);

  //
  if (elems.length > 1) {
    logger.warn(elems.length + " options found ! Choose one randomly");
    elems[0] = elems[Math.floor(Math.random() * elems.length)];
  } else if (elems.length === 0) {
    logger.error("0 option found !");
    return false;
  }

  if (elems[0].tagName == "OPTION") {
    elems[0].selected = true;
    elems[0].parentNode.dispatchEvent(new CustomEvent("change", {"canBubble":false, "cancelable":true}));
  } else {
    elems[0].dispatchEvent(new CustomEvent("mouseover", {"canBubble":true, "cancelable":true}));
    elems[0].dispatchEvent(new CustomEvent("click", {"canBubble":true, "cancelable":true}));
    try { elems[0].click(); } catch(err) {}
  }

  return true;
};

//
Crawler.prototype.searchField = function (field, paths) {
  var elems, i, l, path;

  if (field.search(/^option/) !== -1)
    return this.searchOption(paths);
  if (! paths)
    return $();
  if (! (paths instanceof Array))
    throw ("ArgumentError : was waiting an Array of String, and got a " + (typeof paths));

  for (i = 0, l=paths.length ; i < l ; i++) {
    path = paths[i];
    elems = $(path, this.doc);
    if (elems.length === 0)
      continue;
    if (field === 'image_url' || field === 'images') {
      elems = this.searchImages(field, elems);
      if (field === 'image_url')
        elems = elems.eq(0);
    }
    elems.saturnPath = path;
    break;
  }
  return elems || $();
};

//
Crawler.prototype.parseImage = function (elems) {
  return $unique( elems.toArray().map(function (img) {
    return img.src || img.getAttribute("src");
  }) );
};

//
Crawler.prototype.parseText = function (elems) {
  return elems.toArray().map(function(elem) {
    var res;
    if (elem.tagName === 'IMG')
      res = [elem.getAttribute("alt"), elem.getAttribute("title")].filter(function(txt){return txt;}).join(', ');
    else
      res = elem.innerText || $(elem).text();
    res = res.replace(/\n/g,' ').replace(/ {2,}/g,' ').replace(/^\s+|\s+$/g,'');
    return res;
  }).filter(function(txt) {return txt;}).join(", ") || undefined;
};

//
Crawler.prototype.parseHtml = function (elems) {
  return elems.toArray().map(function(elem) { return elem.innerHTML.replace(/[ \t]{2,}/g,' ').replace(/(\s*\n\s*)+/g,"\n"); }).join("\n<br>\n<!-- SHOPELIA-END-BLOCK -->") || undefined;
};

//
Crawler.prototype.parseField = function (field, elems) {
  var res, images;
  // Merchant specific processing.
  if (this.helper && this.helper.parseField) {
    if (typeof this.helper.parseField === 'function')
      res = this.helper.parseField.call(this, field, elems);
    else if (typeof this.helper.parseField === 'object' && typeof this.helper.parseField[field] === 'function')
      res = this.helper.parseField[field].call(this, elems);
    if (res !== undefined)
      return res;
  }
  // Generic processing
  switch (field) {
  case 'image_url' :
    return this.parseImage(elems)[0];
  case 'images' :
    images = this.parseImage(elems);
    return images.length > 0 ? images : undefined;
  case 'description' :
    return this.parseHtml(elems);
  default :
    return this.parseText(elems);
  }
};

//
Crawler.prototype.crawlField = function (fieldMap, field) {
  var elems;
  if (! fieldMap.paths)
    return '';
  elems = this.searchField(field, fieldMap.paths);
  return this.parseField(field, elems);
};

Crawler.prototype.crawl = function (mapping) {
  var field, result = {};
  for (field in mapping)
    if (field.search(/^option/) === -1) {

      result[field] = this.crawlField(mapping[field], field);
    }
  return result;
};

//
Crawler.prototype.fastCrawl = function (mapping) {
  var field, result = {};
  for (field in mapping)
    result[field] = this.crawlField(mapping[field], field);
  return result;
};

return Crawler;

});
