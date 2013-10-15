// Saturn Crawler.
// Author : Vincent Renaudineau
// Created at : 2013-09-20

define(["jquery", "html_utils", "satconf"], function($, hu) {

var OPTION_FILTER = /choi|choo|s(é|e)lect|toute|^\s*taille\s*$|couleur/i;

function getFromSelectOptions(elem) {
  return elem.find("option:enabled");
}

function getFromUlOptions(elem) {
  return elem.find("li:visible");
}

function searchImagesOptions(elems) {
  var res = elems.find("img:visible");
  return res.length > 0 ? res : null;
}

function searchBackgroudImagesOptions(elems) {
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

function get_src(img) {
  return img.src;
}

var Crawler = {};

Crawler.getOptions = function(pathes) {
  var elems = [], path, options, i, tmp_elems;

  if (! pathes) return [];
  if (! (pathes instanceof Array))
    pathes = [pathes];

  for (i = 0, l = pathes.length; i < l ; i++) {
    path = pathes[i];
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
      tmp_elems = getFromUlOptions(elems);
      if (tmp_elems) {
        elems = tmp_elems;
        tmp_elems = searchImagesOptions(elems);
        if (tmp_elems && tmp_elems.length == elems.length)
          elems = tmp_elems;
      }
    // If a single element is found, search images inside.
    } else if (elems.length == 1) {
      tmp_elems = searchImagesOptions(elems);
      if (tmp_elems) elems = tmp_elems;
    } else {
      tmp_elems = searchBackgroudImagesOptions(elems);
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

Crawler.setOption = function(pathes, option) {
  var elems, path, i, elem;

  if (! pathes) return [];
  if (! (pathes instanceof Array))
    pathes = [pathes];

  for (i = 0, l = pathes.length; i < l ; i++) {
    path = pathes[i];
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
      console.warn("No option found foor path '"+path+"' in elems", elems, "for option", elem);
      continue;
    }
    if (elem.tagName == "OPTION") {
      elem.selected = true;
      elem.parentNode.dispatchEvent(new CustomEvent("change", {"canBubble":false, "cancelable":true}));
    } else
      elem.click();
    return true;
  }
  console.error("No element found for pathes", pathes);
  return false;
};

Crawler.crawl = function(mapping) {
  var option = {},
      textFields = ['name', 'brand', 'description', 'price', 'price_strikeout', 'price_shipping', 'shipping_info', 'availability'],
      imageFields = ['image_url', 'images'],
      i, j, key, pathes, path, e, values, images;

  for (i = 0, li=textFields.length ; i < li ; i++) {
    key = textFields[i];
    if (! mapping[key]) continue;
    if (mapping[key].default_value)
      option[key] = mapping[key].default_value;
    pathes = mapping[key].path;
    if (! pathes) continue;
    if (! (pathes instanceof Array))
      pathes = [pathes];
    for (j = 0, lj=pathes.length ; j < lj ; j++) {
      path = pathes[j];
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
    pathes = mapping[key].path;
    if (! pathes) continue;
    if (! (pathes instanceof Array))
      pathes = [pathes];
    for (j = 0, lj=pathes.length ; j < lj ; j++) {
      path = pathes[j];
      e = $(path);
      if (e.length === 0) continue;
      images = e.add(e.find("img")).filter("img");
      if (images.length === 0) continue;
      values = images.toArray().map(get_src).unique();
      if (key == 'image_url')
        values = values[0];
      option[key] = values;
      break;
    }
  }
  return option;
};

Crawler.doNext = function(action, mapping, option, value) {
  var result,
      key = "option"+(option);
  switch(action) {
    case "getOptions":
      result = mapping[key] ? Crawler.getOptions(mapping[key].path) : [];
      break;
    case "setOption":
      result = Crawler.setOption(mapping[key].path, value);
      break;
    case "crawl":
      result = Crawler.crawl(mapping);
      break;
    default:
      console.error("Unknow command", action);
      result = false;
  }
  return result;
};

return Crawler;

});
