var saturn = {};

(function(that) {

DELAY_BETWEEN_COLORS_OR_SIZES = 1500;
OPTION_FILTER = /choi|choo|s(é|e)lect|toute|^\s*taille\s*$|couleur/i

that.getOptions = function(pathes) {
  if (! pathes) return [];
  if (! (pathes instanceof Array))
    pathes = [pathes];
  for (var i = 0, l = pathes.length; i < l ; i++) {
    var path = pathes[i];
    var elems = $(path);
    var options = [];
    if (elems.length == 0) {
      continue;
    // SELECT, le cas facile
    } else if (elems[0].tagName == "SELECT") {
      elems = elems.eq(0).find("option:enabled");
    // UL, le cas pas trop compliqué
    } else if (elems[0].tagName == "UL") {
      // cherche d'abord les li
      var lis = elems.eq(0).find("li:visible");
      if (lis.length > 0) {
        var imgs = lis.find("img:visible");
        // ensuite on cherche si chaque li contient des images
        if (imgs.length == lis.length)
          elems = imgs;
        else
          elems = lis;
      }
    // If a single element is found, search images inside.
    } else if (elems.length == 1) {
      var imgs = elems.find("img:visible");
      if (imgs.length > 0)
        elems = imgs;
    }
    return _.chain(elems).map(function(elem) {return hu.getElementAttrs(elem)}).
      filter(function(elem) {return elem.text.match(OPTION_FILTER) == null;}).value(); // .uniq()
  }
  return [];
};

that.chooseOption = function(pathes, option) {
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
      console.warning("No option found in", elems, "for option", elem);
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

that.doNext = function(action, mapping, data) {
  var result;
  switch(action) {
    case "getColors":
      result = mapping.colors ? that.getOptions(mapping.colors.path) : [];
      break;
    case "setColor":
      result = that.chooseOption(mapping.colors.path, data);
      break;
    case "getSizes":
      result = mapping.sizes ? that.getOptions(mapping.sizes.path) : [];
      break;
    case "setSize":
      result = that.chooseOption(mapping.sizes.path, data);
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
  var result = saturn.doNext(hash.action, hash.mapping, hash.data);
  if (hash.action == "setColor" || hash.action == "setSize")
    setTimeout(goNextStep, DELAY_BETWEEN_COLORS_OR_SIZES);
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
