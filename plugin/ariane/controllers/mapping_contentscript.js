
/* ********************************************************** */
/*                          On Event                          */
/* ********************************************************** */

function onBodyClick(event) {
  // Si on est sur mac on regarde la metaKey (==pomme) sinon la ctrlKey
  if (! (navigator.platform.match(/mac/i) ? event.metaKey : event.ctrlKey))
    return;

  event.preventDefault();
  var e = $(event.target);
  // var tmpColor = e.css("background-color");
  // var tmpPad = e.css("padding");
  // e.animate({backgroundColor: "#00dd00", padding: 1},100).delay(400).animate({backgroundColor: tmpColor, padding: tmpPad},100);
  var path = hu.getElementCSSSelectors(e);
  var fieldId = getCurrentFieldId();
  setMapping(fieldId, path);
};

/* ********************************************************** */
/*                          Utilities                         */
/* ********************************************************** */

// May be use be the user in the console.
function setMapping(fieldId, path) {
  var elems = document.querySelectorAll(path);
  $(elems).effect("highlight", {color: "#00cc00" }, "slow");
  console.log("Set mapping for '"+fieldId+"' at '"+path+"'.", elems.length, "elements found.");
  var context = elems.length == 1 ? hu.getElementContext(elems[0]) : {};
  chrome.extension.sendMessage({setMapping: true, fieldId: fieldId, path: path, context: context});
};

/* ********************************************************** */
/*                        Initialisation                      */
/* ********************************************************** */

$(document).ready(function() {
  $("body").click(onBodyClick);
  $("body").on("contextmenu", onBodyClick);
  startHumanis(true);
});
