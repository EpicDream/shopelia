//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-24

define(['jquery', 'logger', 'viking', 'html_utils', 'lib/path_utils', 'controllers/toolbar_contentscript', 'src/ari-panel'],
function($, logger, viking, hu, pu, ari_toolbar, panel) {
  "use strict";

  var mapper = {};

  var buttons = [],
      url = window.location.href,
      host = viking.getHost(url),
      data;

  /* ********************************************************** */
  /*                        Initialisation                      */
  /* ********************************************************** */

  chrome.extension.onMessage.addListener(function(msg, sender) {
    if (sender.id !== chrome.runtime.id)
      return;

    if (msg.action === 'initialCrawl' || msg.action === 'updateCrawl') {
      updateFieldMatching();
    }
  });

  mapper.start = function() {
    chrome.storage.local.get('mappings', function(hash) {
      mapper.mapping = data = hash.mappings[url].data;
      mapper.init();
    });
  };

  mapper.init = function() {
    buttons = $("#ariane-toolbar button[id^='ariane-product-']");
    buttons.addClass("missing");

    $("body").click(onBodyClick);
    $("body").on("contextmenu", onBodyClick);

    // on body elemments hover, border them.
    $("body *").hover(function(event) {
      if (event.target != this) return;
      // on ajoute le border à l'élément sur lequel on arrive et l'enlève à celui qu'on quitte
      this.classList.add("ari-surround");
      if (event.relatedTarget)
        event.relatedTarget.classList.remove("ari-surround");
    }, function(event) {
      if (event.target != this) return;
      // on enlève le border de l'élément qu'on quitte et l'ajoute à celui sur lequel on arrive
      this.classList.remove("ari-surround");
      if (event.relatedTarget)
        event.relatedTarget.classList.add("ari-surround");
    });

    ari_toolbar.startAriane(true);
    panel.show();
    updateFieldMatching();
  };

  /* ********************************************************** */
  /*                          On Event                          */
  /* ********************************************************** */

  function onBodyClick(event) {
    // Si on est sur mac on regarde la metaKey (==pomme) sinon la ctrlKey
    if (! (navigator.platform.match(/mac/i) ? event.metaKey : event.ctrlKey))
      return;

    event.preventDefault();

    var fieldId = ari_toolbar.getCurrentFieldId();
    if (! fieldId)
      return alert("Aucun champ sélectionné.");

    // On enlève le ari-surround
    event.target.classList.remove("ari-surround");
    var path = pu.getMinimized(event.target);
    mapper.setMapping(fieldId, path);
    // On remet le ari-surround
    event.target.classList.add("ari-surround");
  }

  /* ********************************************************** */
  /*                          Utilities                         */
  /* ********************************************************** */

  // May be use be the user in the console.
  mapper.setMapping = function(fieldId, path) {
    var elems = $(path);
    elems.effect("highlight", {color: "#00cc00" }, "slow");
    logger.info("setMapping('"+fieldId+"', '"+path+"')", elems.length, "element(s) found.");
    var context = elems.length == 1 ? hu.getElementContext(elems[0]) : {};

    var map = {};
    map[fieldId] = {path: path, context: context};
    mergeMappings(map);

    chrome.storage.local.get('mappings', function(hash) {
      hash.mappings[url].data = data;
      chrome.storage.local.set(hash);
    });

    rematchWithMapping(viking.buildMapping(url, data));
  };

  function rematchWithMapping(mapping) {
    chrome.extension.sendMessage({action: "crawlPage", url: url, mapping: mapping, kind: 'update'});
  }

  function updateFieldMatching() {
    chrome.storage.local.get('crawlings', function(hash) {
      var crawlResults = hash.crawlings[url].update || hash.crawlings[url].initial;
      if (! crawlResults)
        return;
      logger.info("Crawl results :", crawlResults);
      buttons.removeClass('mapped').addClass('missing');
      for (var key in crawlResults)
        if (crawlResults[key]) {
          var b = buttons.filter("#ariane-product-"+key);
          b.removeClass("missing").addClass("mapped");
        }
    });
  }

  // Merge new mapping in the previous one.
  // Try to know if a mapping must be added before (it is more specific)
  // or after (it is less specific) existing ones.
  function mergeMappings(currentMap) {
    // GOING TO MERGE NEW MAPPING WITH OLD ONES
    // create new host rule if it did not exist.
    logger.debug('Going to merge', currentMap, 'in', data.viking);

    //
    var possibleHosts = viking.compatibleHosts(host, data);

    for (var key in currentMap) {
      // if no new map, continue
      if (! currentMap[key])
        continue;

      // On choisit le bon host, général ou spécific.
      var goodHost;
      if (possibleHosts.length > 1) {
        goodHost = prompt("Pour quel host ce chemin est-il valide ?\n"+possibleHosts.join("\n"));
        if (! goodHost) {
          logger.warn("key '"+key+"' with new path '"+newPath+"' skiped.");
          continue;
        }
      } else
        goodHost = possibleHosts[0];

      // On initialize la structure si elle n'existant pas.
      if (! data.viking[goodHost])
        data.viking[goodHost] = {};
      var mapping = data.viking[goodHost];
      if (! mapping[key]) mapping[key] = {path: [], context: []};
      if (! mapping[key].path) mapping[key].path = [];
      if (! mapping[key].context) mapping[key].context = [];

      var newPath = currentMap[key].path;
      var oldPath = mapping[key].path;
      logger.debug('Merge for key "'+key+'", "'+newPath+'" in "'+oldPath+'"');

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
      if (oldPath.filter(function(e) {return e.indexOf(newPath) !== -1;}).length > 0) {
        logger.debug(oldPath, "already contains", newPath);
        continue;
      }

      var newMatch = $(newPath);
      for (var i = 0, l = oldPath.length ; i < l ; i++) {

        var str = "Pour le nouveau path \""+newPath+"\",\n" + "et l'ancien path \""+oldPath[i]+"\",\n",
            previousMatch = $(oldPath[i]);
        if (previousMatch.length == newMatch.length && $.makeArray(previousMatch) == $.makeArray(newMatch)) {
          alert(str + "les mêmes éléments sont capturés.");
        } else
          alert(str + previousMatch.length + " éléments étaient capturés avant, " + newMatch.length + " maintenant.");

        if (confirm(str + "concaténer les paths ?")) {
          oldPath[i] += ", "+newPath;
          break;
        } else if (confirm(str + "remplacer le path ?")) {
          oldPath.splice(i,1,newPath);
          break;
        } else if (confirm(str + "Le placer juste avant ?" + (i > 0 ? "\nPrécédent : \""+oldPath[i-1]+"\"." : ''))) {
          oldPath.splice(i,0,newPath);
          break;
        } else if (confirm(str + "Le placer juste après ?" + (i < l-1 ? "\nSuivant : \""+oldPath[i+1]+"\"." : ''))) {
          oldPath.splice(i+1,0,newPath);
          break;
        } else if (i < l-1 && ! confirm("Passer au path suivant ? (sinon on annule)")) {
          break;
        } else if (i < l-1 && ! confirm("Reposer les questions pour ce path ?")) {
          i = i-1;
          continue;
        }
      }
      // Par défaut on rajoute à la suite
      if (i == l) {
        if (l > 0)
          alert("On ajoute ce path à la suite des autres.");
        oldPath.push(newPath);
      }
    }
  }

  return mapper;
});