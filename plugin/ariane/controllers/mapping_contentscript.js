
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

// Merge new mapping in the previous one.
// Try to know if a mapping must be added before (it is more specific)
// or after (it is less specific) existing ones.
function mergeMappings(currentMap, mapping) {
  // GOING TO MERGE NEW MAPPING WITH OLD ONES
  // create new host rule if it did not exist.
  console.log('Going to merge', currentMap, 'in', mapping);

  for (var key in jQuery.extend({}, mapping, currentMap)) {
    // if no new map, continue
    if (! currentMap[key])
      continue;

    var newPath = currentMap[key].path;
    var oldPath = mapping[key].path;
    console.log('Merge key', key, newPath, oldPath);

    // if it did not exist, just create it and continue.
    if (! oldPath) {
      mapping[key] = {path: [newPath], context: [currentMap[key].context]};
      continue;
    }
    // if old version, update it.
    if (! (oldPath instanceof Array)) {
      mapping[key] = {path: [oldPath], context: [mapping[key].context]};
      oldPath = mapping[key].path;
    }
    // if already contains it, pass
    if (oldPath.filter(function(e) {return e.match('^\s*'+newPath+'\s*(?:,|$)');}).length > 0) {
      console.log(oldPath, "already contains", newPath);
      continue;
    }

    var newMatch = $(newPath);
    for (var i = 0, l = oldPath.length ; i < l ; i++) {
      var previousMatch = $(oldPath[i]);
      // if elems is already match
      if (previousMatch.length == newMatch.length && $.makeArray(previousMatch) == $.makeArray(newMatch)) {
        if (confirm(currentMap[key]+"\nL'élément était déjà capturé : remplacer le path ? ("+oldPath[i]+")")) {
          oldPath.splice(i,1,newPath);
          mapping[key].context.splice(i,1,currentMap[key].context);
          break;
        } else if (confirm("Le placer avant ?")) {
          oldPath.splice(i,0,newPath);
          mapping[key].context.splice(i,0,currentMap[key].context);
          break;
        }
      } else if (previousMatch.length > newMatch.length) {
        if (confirm(currentMap[key]+"\nL'élément était déjà capturé, mais d'autres éléments aussi : remplacer le path ? ("+oldPath[i]+")")) {
          oldPath.splice(i,1,newPath);
          mapping[key].context.splice(i,1,currentMap[key].context);
          break;
        } else if (confirm("Le placer avant ?")) {
          oldPath.splice(i,0,newPath);
          mapping[key].context.splice(i,0,currentMap[key].context);
          break;
        }
        break;
      } else {
        console.log("concat ? before ? after ?", previousMatch, newMatch);
        if (confirm(newMatch.length+" éléments capturés avec le nouveau path, "+previousMatch.length+" avec l'ancien : concaténer les paths ?")) {
          oldPath[i] += ", "+newPath;
          mapping[key].context.splice(i,0,currentMap[key].context);
          break;
        }
        // previousMatch.length < newMatch.length
          // concaténer ?
          // remplacer ?
        // OU previousMatch != newMatch
          // concaténer ?
          // remplacer ?
          // placer avant ?
          // placer après ?
      }
    }
    if (i == l) {
      oldPath.push(newPath);
      mapping[key].context.push(currentMap[key].context);
    }

    // // if some elements where already found, unshift new rafinement.
    // if (tasks[tabId].searchResult[key]) {
    //   mapping[key].path.splice(0,0,currentMap[key].path);
    //   mapping[key].context.splice(0,0,currentMap[key].context);
    // // else, if nothing matched, push it behind.
    // } else {
    //   mapping[key].path.push(currentMap[key].path);
    //   mapping[key].context.push(currentMap[key].context);
    // }
  }

  return mapping;
};

/* ********************************************************** */
/*                        Initialisation                      */
/* ********************************************************** */

var started = false,
    buttons = [],
    mapping = null,
    mappingRes = null;

chrome.extension.onMessage.addListener(function(msg, sender, response) {
  if (sender.id != chrome.runtime.id)
    return;

  if (msg.mapping !== undefined && ! started) {
    console.log("Received mapping :", msg.mapping);
    mapping = msg.mapping;
    started = true;
  } else if (msg.act == 'merge') {
    var res = mergeMappings(msg.current, msg.previous);
    response(res);
  }
});

function loadMappingOnJQuery() {
  if (window.jQuery && started && window.jStep) {
    buttons = $("#ariane-toolbar button[id^='ariane-product-']");
    buttons.addClass("missing");

    var mappingRes = search(mapping);
    console.log("Elements found :", mappingRes);
    for (var key in mappingRes)
      if (mappingRes[key].length > 0) {
        var b = buttons.filter("#ariane-product-"+key);
        b.removeClass("missing").addClass("mapped");
      }

    $(document).ready(function() {
      $("body").click(onBodyClick);
      $("body").on("contextmenu", onBodyClick);

      // on body elemments hover, border them.
      $("body *").hover(function(event) {
        if (event.target != this) return;
        // on ajoute le border à l'élément sur lequel on arrive et l'enlève à celui qu'on quitte
        $(this).addClass("ari-surround");
        $(event.relatedTarget).removeClass("ari-surround");
      }, function(event) {
        if (event.target != this) return;
        // on enlève le border de l'élément qu'on quitte et l'ajoute à celui sur lequel on arrive
        $(this).removeClass("ari-surround");
        $(event.relatedTarget).addClass("ari-surround");
      });

      startAriane(true);
    });
  } else
    return setTimeout(loadMappingOnJQuery, 100);
};

loadMappingOnJQuery();
