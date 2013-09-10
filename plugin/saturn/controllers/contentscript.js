var saturn = {};

(function(that) {

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

that.getOptions = function(pathes) {
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

that.setOption = function(pathes, option) {
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
      elem = $xf(".//*[text()='"+option.text+"']", elems[0]);

    if (! elem && option.id)
      elem = elems.filter("#"+option.id)[0];
    if (! elem && option.text)
      elem = $xf(".//*[text()='"+option.text+"']", elems.commonAncestor()[0])
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

that.crawl = function(mapping) {
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
      var values = _.chain(images).map(function(img) {return img.getAttribute("src");}).uniq().value();
      if (key == 'image_url')
        values = values[0];
      option[key] = values;
      break;
    }
  }
  return option;
};

that.doNext = function(action, mapping, level, option) {
  var result,
      key = "option"+(level+1);
  switch(action) {
    case "getOptions":
      result = mapping[key] ? that.getOptions(mapping[key].path) : [];
      break;
    case "setOption":
      result = that.setOption(mapping[key].path, option);
      break;
    case "crawl":
      result = that.crawl(mapping);
      break;
    default:
      console.error("Unknow command", action);
      result = false;
  }
  return result;
};

})(saturn);

chrome.extension.onMessage.addListener(function(hash, sender, callback) {
  if (sender.id != chrome.runtime.id) return;
  console.debug("ProductCrawl task received", hash);
  var result = saturn.doNext(hash.action, hash.mapping, hash.level, hash.option);
  if (hash.action == "setOption")
    setTimeout(goNextStep, DELAY_BETWEEN_OPTIONS);
  else if (callback)
    callback(result);
});

function goNextStep() {
  chrome.extension.sendMessage("nextStep");
};

jQuery.fn.commonAncestor = function() {
  var parents = [];
  var minlen = Infinity;

  $(this).each(function() {
    var curparents = $(this).parents();
    parents.push(curparents);
    minlen = Math.min(minlen, curparents.length);
  });

  for (var i in parents) {
    parents[i] = parents[i].slice(parents[i].length - minlen);
  }

  // Iterate until equality is found
  for (var i = 0; i < parents[0].length; i++) {
    var equal = true;
    for (var j in parents) {
      if (parents[j][i] != parents[0][i]) {
        equal = false;
        break;
      }
    }
    if (equal) return $(parents[0][i]);
  }
  return $([]);
};

// To handle redirection, that throws false 'complete' state.
$(document).ready(function() {
  setTimeout(goNextStep, 100);
});
