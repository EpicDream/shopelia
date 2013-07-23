
function getColors(mapping) {
  if (! mapping.colors)
    return [];
  var path = mapping.colors.path;
  var e = $(path);
  if (e.length == 0)
    return [];
  else if (e[0].tagName == "SELECT") {
    var options = e.eq(0).find("option:enabled");
    var colors = _.map(options, function(opt) {return opt.innerText});
  } else {
    var images = e.find("img");
    if (images.length == 0) return [];
    var colors = _.chain(images).map(function(img) {return img.getAttribute("src");}).uniq().value();
  }
  return colors;
};

function setColor(mapping, color) {
  var path = mapping.colors.path;
  var e = $(path);
  if (e.length == 0) {
    console.error("Unknow tagname for element", e, "and path", path);
    return false;
  } else if (e[0].tagName == "SELECT") {
    var option = e.find("option:contains('"+color+"')");
    option[0].selected = true;
    option.parent().change();
  } else {
    e.find("img[src='"+color+"']").eq(0).click();
  }
  return true;
};

function getSizes(mapping) {
  if (! mapping.sizes)
    return [];
  var path = mapping.sizes.path;
  var e = $(path);
  if (e.length == 0)
    return [];
  else if (e[0].tagName != "SELECT")
    e = e.find("select");
  if (e.length == 0)
    return [];

  var options = e.find("option:enabled");
  var sizes = _.chain(options).map(function(opt) {return opt.innerText}).filter(function(size) {return size.match(/choi|choo/i) == null;}).value();
  return sizes;
};

function setSize(mapping, size) {
  var path = mapping.sizes.path;
  var e = $(path);
  if (e.length > 0 && e[0].tagName == "SELECT") {
    var option = e.eq(0).find("option:contains('"+size+"')");
    option[0].selected = true;
    option.parent().change();
  } else {
    console.error("Unknow tagname for element", e, "and path", path);
    return false;
  }
  return true;
};


function crawl(mapping) {
  var option = {};
  var textFields = ['name', 'brand', 'description', 'price', 'price_strikeout', 'shipping_price', 'shipping_info', 'availability'];
  for (var i in textFields) {
    var key = textFields[i];
    if (! mapping[key]) continue;
    var path = mapping[key].path;
    if (! path) continue;
    var e = $(path);
    if (e.length == 0) continue;
    if (key != 'description')
      option[key] = e.text().replace(/\n/g,'').replace(/ {2,}/g,' ').replace(/^\s+|\s+$/g,'');
    else
      option[key] = e.html().replace(/[ \t]{2,}/g,' ').replace(/(\s*\n\s*)+/g,"\n");

  }
  var imageFields = ['image_url', 'images'];
  for (var i in imageFields) {
    var key = imageFields[i];
    if (! mapping[key]) continue;
    var path = mapping[key].path;
    if (! path) continue;
    var e = $(path);
    if (e.length == 0) continue;
    var images = e.add(e.find("img")).filter("img");
    if (images.length == 0) continue;
    var values = _.chain(images).map(function(img) {return img.getAttribute("src");}).uniq().value();
    if (key == 'image_url')
      values = values[0];
    option[key] = values;
  }
  return option;
};

chrome.extension.onMessage.addListener(function(hash, sender, callback) {
  if (sender.id != chrome.runtime.id) return;
  action = hash.action;
  mapping = hash.mapping;
  data = hash.data;
  result = undefined;
  console.debug("ProductCrawl task received", hash);
  switch(action) {
    case "getColors":
      result = getColors(mapping);
      break;
    case "setColor":
      result = setColor(mapping, data);
      return setTimeout(goNextStep, 500);
      break;
    case "getSizes":
      result = getSizes(mapping);
      break;
    case "setSize":
      result = setSize(mapping, data);
      return setTimeout(goNextStep, 500);
      break;
    case "crawl":
      result = crawl(mapping);
      break;
    default:
      console.error("Unknow command", action);
      result = false;
  }
  if (callback)
    callback(result);
});

function goNextStep() {
  chrome.extension.sendMessage("nextStep");
};

goNextStep();
