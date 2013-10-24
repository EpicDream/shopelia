// Saturn Crawler.
// Author : Vincent Renaudineau
// Created at : 2013-09-20

define(["logger", "jquery", "html_utils", "core_extensions"], function(logger, $, hu) {
  "use strict";

var OPTION_FILTER = /choi|choo|s(é|e)lect|toute|^\s*taille\s*$|couleur/i;

function getFromSelectOptions(elem) {
  return elem.find("option:enabled");
}

function getFromUlOptions_back(elem) {
  return elem.find("li:visible");
}

function searchImagesOptions_back(elems) {
  var res = elems.find("img:visible");
  return res.length > 0 ? res : null;
}

function searchBackgroudImagesOptions_back(elems) {
  // Cas spécifique à Amazon
  if (location.host.match("amazon")) {
    var res = elems.find(".swatchInnerImage[style]").filter(function(i, e) {
      return $(this).css("background-image").search(/url\(.*\)/) !== -1;
    }).each(function() {
      var url = $(this).css("background-image").match(/url\((.*)\)/)[1];
      $(this).parent().parent().attr("src", url);
    }).parent().parent();
    return res.length > 0 ? res : null;
  } else
    return null;
}

function get_src_back(img) {
  return img.src;
}

var Crawler = {};

Crawler.getOptions_back = function(paths) {
  var elems = [], path, options, i, tmp_elems;

  if (! paths) return [];
  if (! (paths instanceof Array))
    paths = [paths];

  for (i = 0, l = paths.length; i < l ; i++) {
    path = paths[i];
    elems = $(path);
    options = [];
    if (elems.length === 0) {
      continue;
    // SELECT, le cas facile
    } else if (elems[0].tagName == "SELECT") {
      elems = elems.eq(0).find("option:enabled");
    // UL, le cas pas trop compliqué
    } else if (elems[0].tagName == "UL") {
      // cherche d'abord les li
      tmp_elems = getFromUlOptions_back(elems);
      if (tmp_elems) {
        elems = tmp_elems;
        tmp_elems = searchImagesOptions_back(elems);
        if (tmp_elems && tmp_elems.length == elems.length)
          elems = tmp_elems;
      }
    // If a single element is found, search images inside.
    } else if (elems.length == 1) {
      tmp_elems = searchImagesOptions_back(elems);
      if (tmp_elems) elems = tmp_elems;
    } else {
      tmp_elems = searchBackgroudImagesOptions_back(elems);
      if (tmp_elems) elems = tmp_elems;
    }
    break;
  }

  return elems.toArray().filter(function(elem) {
    return elem.innerText.match(OPTION_FILTER) === null;
  }).map(function(elem) {
    var h = hu.getElementAttrs(elem);
    h.xpath = hu.getElementXPath(elem);
    h.cssPath = hu.getElementCSSSelectors($(elem));
    h.saturnPath = path;
    h.hash = [h.tagName,h.id,h.text,h.location,h.value,h.src].join(';');
    return h;
  });
};

Crawler.setOption_back = function(paths, option) {
  var elems, path, i, elem;

  if (! paths) return [];
  if (! (paths instanceof Array))
    paths = [paths];

  for (i = 0, l = paths.length; i < l ; i++) {
    path = paths[i];
    elems = $(path);
    if (elems.length === 0)
      continue;
    if (elems[0].tagName == "SELECT")
      elem = elems.find("option:contains("+option.text+")")[0];

    if (! elem && option.id)
      elem = elems.filter("#"+option.id)[0];
    if (! elem && option.text)
      elem = (elem = elems.filter(":contains("+option.text+")")) && elem.length == 1 ? elem[0] : undefined;
    if (! elem && option.src)
      elem = elems.filter("[src='"+option.src+"']")[0];
    if (! elem && option.href)
      elem = elems.filter("[href='"+option.href+"']")[0];
    if (! elem && option.title)
      elem = (elem = elems.filter("[title='"+option.title+"']")) && elem.length == 1 ? elem[0] : undefined;
    if (! elem) {
      logger.warn("No option found foor path '"+path+"' in elems", elems, "for option", elem);
      continue;
    }
    if (elem.tagName == "OPTION") {
      elem.selected = true;
      elem.parentNode.dispatchEvent(new CustomEvent("change", {"canBubble":false, "cancelable":true}));
    } else
      elem.click();
    return true;
  }
  logger.error("No element found for paths", paths);
  return false;
};

Crawler.crawl_back = function(mapping) {
  var option = {},
      textFields = ['name', 'brand', 'description', 'price', 'price_strikeout', 'price_shipping', 'shipping_info', 'availability'],
      imageFields = ['image_url', 'images'],
      i, j, key, paths, path, e, values, images;

  for (i = 0, li=textFields.length ; i < li ; i++) {
    key = textFields[i];
    if (! mapping[key]) continue;
    if (mapping[key].default_value)
      option[key] = mapping[key].default_value;
    paths = mapping[key].path;
    if (! paths) continue;
    if (! (paths instanceof Array))
      paths = [paths];
    for (j = 0, lj=paths.length ; j < lj ; j++) {
      path = paths[j];
      e = $(path);
      if (e.length === 0) continue;
      if (key !== 'description') {
        option[key] = e.toArray().map(function(elem) {
          var res;
          if (elem.tagName === 'IMG')
            res = [elem.getAttribute("alt"), elem.getAttribute("title")].filter(function(txt){return txt;}).join(', ');
          else
            res = elem.innerText;
          res = res.replace(/\n/g,' ').replace(/ {2,}/g,' ').replace(/^\s+|\s+$/g,'');
          return res;
        }).filter(function(txt) {return txt;}).join(", ");
      } else
        option[key] = e.toArray().map(function(elem) { return elem.innerHTML.replace(/[ \t]{2,}/g,' ').replace(/(\s*\n\s*)+/g,"\n"); }).join("\n<br>\n");
      if (option[key] !== "")
        break;
    }
  }
  for (i = 0, li=imageFields.length ; i < li ; i++) {
    key = imageFields[i];
    if (! mapping[key]) continue;
    if (mapping[key].default_value)
      option[key] = mapping[key].default_value;
    paths = mapping[key].path;
    if (! paths) continue;
    if (! (paths instanceof Array))
      paths = [paths];
    for (j = 0, lj=paths.length ; j < lj ; j++) {
      path = paths[j];
      e = $(path);
      if (e.length === 0) continue;
      images = e.add(e.find("img")).filter("img:visible");
      if (images.length === 0) continue;
      values = images.toArray().map(get_src_back).unique();
      if (key == 'image_url')
        values = values[0];
      option[key] = values;
      break;
    }
  }
  return option;
};

// ###########################################################

//
function searchImagesOptions(elems) {
  var size = elems.length;

  elems = elems.find("img:visible").addBack("img:visible");
  if (elems.length === size)
    return elems;
  else if (location.host.match("amazon")) {
    elems = elems.end().end().find(".swatchInnerImage[style]").filter(function(i, e) {
      return $(this).css("background-image").search(/url\(.*\)/) !== -1;
    });
    if (elems.length === size)
      elems = elems.each(function() {
        var url = $(this).css("background-image").match(/url\((.*)\)/)[1];
        $(this).parent().parent().attr("src", url);
      }).parent().parent();
    else
      elems = $();
  } else
    elems = $();

  return elems;
}

//
Crawler.searchOption = function (paths, doc) {
  var elems, i, l, path, tmp_elems, nbOptions;

  if (! paths)
    return $();
  if (! (paths instanceof Array)) {
    if (typeof paths === 'string')
      paths = [paths];
    else
      throw "ArgumentError : was waiting an Array of String, and got a " + (typeof paths);
  }
  doc = doc || window.document;

  for (i = 0, l = paths.length; i < l ; i++) {
    path = paths[i];
    elems = $(path, doc);
    options = [];
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
Crawler.parseOption = function (elems) {
  return elems.toArray().filter(function(elem) {
    return elem.innerText.match(OPTION_FILTER) === null;
  }).map(function(elem) {
    var h = hu.getElementAttrs(elem);
    h.xpath = hu.getElementXPath(elem);
    h.cssPath = hu.getElementCSSSelectors($(elem));
    h.saturnPath = elems.saturnPath;
    h.hash = [h.tagName,h.id,h.text,h.location,h.value,h.src].join(';');
    return h;
  });
};

// Return an array of option's value.
Crawler.getOptions = function (paths, doc) {
  var elems = Crawler.searchOption(paths, doc);
  return Crawler.parseOption(elems);
};

// Return a jQuery instance.
Crawler.selectOption = function (elems, value) {
  if (elems.length === 0)
    return $();

  var backup = elems;

  if (elems[0].tagName === "OPTION") {
    elems = elems.filter(":contains("+value.text+")");
    if (elems.length === 0) elems.end(); // undo last filter.
  }
  if (elems.length > 1 && elems[0].tagName === "OPTION") {
    elems = elems.filter("[value='"+value.value+"']");
    if (elems.length === 0) elems.end(); // undo last filter.
  }
  if (elems.length > 1 && value.id) {
    elems = elems.filter("#"+value.id);
    if (elems.length === 0) elems.end(); // undo last filter.
  }
  if (elems.length > 1 && value.text) {
    elems = elems.filter(":contains("+value.text+")");
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
  if (elems.length > 1 && value.title) {
    elems = elems.filter("[title='"+value.title+"']");
    if (elems.length === 0) elems.end(); // undo last filter.
  }

  return elems;
};

//
Crawler.setOption = function(paths, value, doc) {
  var elems = Crawler.searchOption(paths, doc);
  elems = Crawler.selectOption(elems, value);

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
  } else
    elems[0].click();

  return true;
};

//
Crawler.searchField = function (field, paths, doc) {
  var elems, i, l, path;

  if (field.search(/^option/) !== -1)
    return Crawler.searchOption(paths, doc);
  if (! paths)
    return $();
  if (! (paths instanceof Array)) {
    if (typeof paths === 'string')
      paths = [paths];
    else
      throw "ArgumentError : was waiting an Array of String, and got a " + (typeof paths);
  }
  doc = doc || window.document;

  for (i = 0, l=paths.length ; i < l ; i++) {
    path = paths[i];
    elems = $(path, doc);
    if (elems.length === 0)
      continue;
    if (field === 'image_url' || field === 'images') {
      elems = elems.add(elems.find("img")).filter("img").sort(function(i1, i2) {
        return (i2.height * i2.width) - (i1.height * i1.width);
      });
      if (field === 'image_url')
        elems = elems.eq(0);
    }
    elems.saturnPath = path;
    break;
  }
  return elems || $();
};

//
Crawler.parseImage = function (elems) {
  return elems.toArray().map(function (img) {
    return img.src;
  }).unique();
};

//
Crawler.parseText = function (elems) {
  return elems.toArray().map(function(elem) {
    var res;
    if (elem.tagName === 'IMG')
      res = [elem.getAttribute("alt"), elem.getAttribute("title")].filter(function(txt){return txt;}).join(', ');
    else
      res = elem.innerText || $(elem).text();
    res = res.replace(/\n/g,' ').replace(/ {2,}/g,' ').replace(/^\s+|\s+$/g,'');
    return res;
  }).filter(function(txt) {return txt;}).join(", ");
};

//
Crawler.parseHtml = function (elems) {
  return elems.toArray().map(function(elem) { return elem.innerHTML.replace(/[ \t]{2,}/g,' ').replace(/(\s*\n\s*)+/g,"\n"); }).join("\n<br>\n");
};

//
Crawler.parseField = function (field, elems) {
  var images;
  switch (field) {
  case 'image_url' :
  case 'images' :
    images = Crawler.parseImage(elems);
    return field === 'image_url' ? images[0] : images;
  case 'description' :
    return Crawler.parseHtml(elems);
  default :
    return Crawler.parseText(elems);
  }
};

//
Crawler.crawlField = function (fieldMap, field, doc) {
  var elems;
  if (! fieldMap.path)
    return '';
  elems = Crawler.searchField(field, fieldMap.path, doc);
  return Crawler.parseField(field, elems);
};

Crawler.crawl = function (mapping, doc) {
  var field, result = {};
  for (field in mapping)
    if (field.search(/^option/) === -1) {

      result[field] = Crawler.crawlField(mapping[field], field, doc) || mapping[field].default_value;
    }
  return result;
};

//
Crawler.fastCrawl = function (mapping, doc) {
  var field, result = {};
  for (field in mapping)
    result[field] = Crawler.crawlField(mapping[field], field, doc) || mapping[field].default_value;
  return result;
};

return Crawler;

});
