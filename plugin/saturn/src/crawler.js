// Saturn Crawler.
// Author : Vincent Renaudineau
// Created at : 2013-09-20

(function() {

DELAY_BETWEEN_OPTIONS = 1500;
OPTION_FILTER = /choi|choo|s(é|e)lect|toute|^\s*taille\s*$|couleur/i

function getFromSelectOptions(elem) {
  return elem.find("option:enabled");
};

function getFromUlOptions(elem) {
  return elem.find("li:visible");
};

function searchImagesOptions(elems) {
  var res = elems.find("img:visible");
  return res.length > 0 ? res : null;
};

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
};

var Crawler = {};

Crawler.getOptions = function(pathes) {
  if (! pathes) return [];
  if (! (pathes instanceof Array))
    pathes = [pathes];
  for (var i = 0, l = pathes.length; i < l ; i++) {
    var path = pathes[i];
    var elems = $(path), tmp_elems;
    var options = [];
    if (elems.length == 0) {
      continue;
    // SELECT, le cas facile
    } else if (elems[0].tagName == "SELECT") {
      elems = elems.eq(0).find("option:enabled");
    // UL, le cas pas trop compliqué
    } else if (elems[0].tagName == "UL") {
      // cherche d'abord les li
      if (tmp_elems = getFromUlOptions(elems)) {
        elems = tmp_elems;
        tmp_elems = searchImagesOptions(elems);
        if (tmp_elems.length == elems.length)
          elems = tmp_elems;
      }
    // If a single element is found, search images inside.
    } else if (elems.length == 1) {
      if (tmp_elems = searchImagesOptions(elems)) elems = tmp_elems;
    } else {;
      if (tmp_elems = searchBackgroudImagesOptions(elems)) elems = tmp_elems;
    }
    return $.makeArray(elems).filter(function(elem) {
      return elem.innerText.match(OPTION_FILTER) == null;
    }).map(function(elem) {
      var h = hu.getElementAttrs(elem);
      h.xpath = hu.getElementXPath(elem);
      h.cssPath = hu.getElementCSSSelectors($(elem));
      h.saturnPath = path;
      return h;
    });
  }
  return [];
};

Crawler.setOption = function(pathes, option) {
  if (! pathes) return [];
  if (! (pathes instanceof Array))
    pathes = [pathes];
  for (var i = 0, l = pathes.length; i < l ; i++) {
    var path = pathes[i];
    var elems = $(path);
    if (elems.length == 0)
      continue;
    var elem = undefined;
    if (elems[0].tagName == "SELECT")
      elem = elems.find("option:contains("+option.text+")")[0];

    if (! elem && option.id)
      elem = elems.filter("#"+option.id)[0];
    if (! elem && option.text)
      elem = elems.find("option:contains("+option.text+")")[0];
    if (! elem && option.src)
      elem = elems.filter("[src='"+option.src+"']")[0];
    if (! elem && option.href)
      elem = elems.filter("[href='"+option.href+"']")[0];
    if (! elem) {
      console.warn("No option found in", elems, "for option", elem);
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
  var option = {};
  var textFields = ['name', 'brand', 'description', 'price', 'price_strikeout', 'price_shipping', 'shipping_info', 'availability'];
  for (var i = 0, li=textFields.length ; i < li ; i++) {
    var key = textFields[i];
    if (! mapping[key]) continue;
    if (mapping[key].default_value)
      option[key] = mapping[key].default_value;
    var pathes = mapping[key].path;
    if (! pathes) continue;
    if (! (pathes instanceof Array))
      pathes = [pathes];
    for (var j = 0, lj=pathes.length ; j < lj ; j++) {
      var path = pathes[j];
      var e = $(path);
      if (e.length == 0) continue;
      if (key != 'description') {
        if (e.length == 1 && e[0].tagName == "IMG")
          option[key] = [e.attr("alt"), e.attr("title")].join(', ');
        else
          option[key] = e.text();
        option[key] = option[key].replace(/\n/g,'').replace(/ {2,}/g,' ').replace(/^\s+|\s+$/g,'');
      } else
        option[key] = e.html().replace(/[ \t]{2,}/g,' ').replace(/(\s*\n\s*)+/g,"\n");
      if (option[key] != "")
        break;
    }
  }
  var imageFields = ['image_url', 'images'];
  for (var i = 0, li=imageFields.length ; i < li ; i++) {
    var key = imageFields[i];
    if (! mapping[key]) continue;
    if (mapping[key].default_value)
      option[key] = mapping[key].default_value;
    var pathes = mapping[key].path;
    if (! pathes) continue;
    if (! (pathes instanceof Array))
      pathes = [pathes];
    for (var j in pathes) {
      var path = pathes[j];
      var e = $(path);
      if (e.length == 0) continue;
      var images = e.add(e.find("img")).filter("img");
      if (images.length == 0) continue;
      var values = $.makeArray(images).map(function(img) {return img.getAttribute("src");}).unique();
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

if ("object" == typeof module && module && "object" == typeof module.exports)
  exports = module.exports = Crawler;
else if ("function" == typeof define && define.amd)
  define("crawler", ["jquery", "html_utils"], function(){return Crawler});
else
  window.Crawler = Crawler;

})();
