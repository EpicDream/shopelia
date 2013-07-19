
function getColors(mapping) {
  if (! mapping.colors)
    return [];
  var path = mapping.colors.path;
  var e = document.querySelector(path);
  if (! e)
    return [];
  else if (e.tagName == "SELECT") {
    var options = e.querySelectorAll("option:enabled");  
    var colors = _.map(options, function(opt) {return opt.innerText});
  } else {
    var images = e.querySelectorAll("img");
    if (images.length == 0) return [];
    var colors = _.chain(images).map(function(img) {return img.getAttribute("src");}).uniq().value();
  }
  return colors;
};

function setColor(mapping, color) {
  var path = mapping.colors.path;
  var e = document.querySelector(path);

  if (e && e.tagName == "SELECT") {
    var option = $(e).find("option:contains('"+color+"')");
    option[0].selected = true;
    option.parent().change();
    return true;
  } else if (e) {
    $(e).find("img[src='"+color+"']").eq(0).click();
    return true;
  } else
    console.error("Unknow tagname for element", e, "and path", path);
  return false;
};

function getSizes(mapping) {
  if (! mapping.sizes)
    return [];
  var path = mapping.sizes.path;
  var e = document.querySelector(path);
  if (! e)
    return [];
  else if (! e.tagName == "SELECT")
    e = e.querySelector("select");

  if (! e) 
    return [];

  var options = e.querySelectorAll("option:enabled");
  var sizes = _.chain(options).map(function(opt) {return opt.innerText}).filter(function(size) {return size.match(/choi|choo/i) == null;}).value();
  return sizes;
};

function setSize(mapping, size) {
  var path = mapping.sizes.path;
  var e = document.querySelector(path);
  
  if (e && e.tagName == "SELECT") {
    var option = $(e).find("option:contains('"+size+"')");
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
    var e = document.querySelector(path);
    if (! e) continue;
    var value = e.innerText;
    option[key] = value;
  }
  var imageFields = ['image_url', 'images'];
  for (var i in imageFields) {
    var key = imageFields[i];
    if (! mapping[key]) continue;
    var path = mapping[key].path;
    if (! path) continue;
    var e = document.querySelector(path);
    if (! e) continue;
    var images = e.querySelectorAll("img");
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
  var action = hash.action;
  var mapping = hash.mapping;
  var data = hash.data;
  var result;
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
