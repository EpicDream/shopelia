
/* ********************************************************** */
/*                          On Event                          */
/* ********************************************************** */

function onBodyClick(event) {
  // Si on est sur mac on regarde la metaKey (==pomme) sinon la ctrlKey
  if (! (navigator.platform.match(/mac/i) ? event.metaKey : event.ctrlKey))
    return;

  event.preventDefault();
  var path = pu.getMinimized(event.target);
  var fieldId = getCurrentFieldId();
  setMapping(fieldId, path);
};

/* ********************************************************** */
/*                          Utilities                         */
/* ********************************************************** */

// May be use be the user in the console.
function setMapping(fieldId, path) {
  var elems = $(path);
  elems.effect("highlight", {color: "#00cc00" }, "slow");
  console.log("setMapping('"+fieldId+"', '"+path+"')", elems.length, "element(s) found.");
  var context = elems.length == 1 ? hu.getElementContext(elems[0]) : {};
  buttons.filter("#ariane-product-"+fieldId).removeClass("missing").addClass("mapped");
  chrome.extension.sendMessage({act: 'setMapping', fieldId: fieldId, value: {path: path, context: context}});
};

function search(mapping) {
  var res = {}
  for (var key in mapping) {
    var paths = mapping[key].path;
    if (! paths) continue;
    if (! (paths instanceof Array))
      paths = [paths];
    for (var j in paths) {
      var path = paths[j];
      var elems = $(path);
      if (elems.length == 0) continue;
      res[key] = elems;
      break;
    }
  }
  return res;
};

/* ********************************************************** */
/*                        Initialisation                      */
/* ********************************************************** */

var buttons = $("#ariane-toolbar button[id^='product-']");

$(document).ready(function() {
  $("body").click(onBodyClick);
  $("body").on("contextmenu", onBodyClick);
});

chrome.extension.onMessage.addListener(function(msg, sender) {
  if (sender.id != chrome.runtime.id || ! msg.mapping)
    return;

  console.log("Received mapping :", msg.mapping);
  var res = search(msg.mapping);
  console.log("Elements found :", res);
  buttons.addClass("missing");
  for (var key in res)
    if (res[key].length > 0)
      buttons.filter("#ariane-product-"+key).removeClass("missing").addClass("mapped");

  for (var key in res)
    res[key] = res[key].length;
  chrome.extension.sendMessage({act: 'setSearchResult', value: res});

  startHumanis(true);
});