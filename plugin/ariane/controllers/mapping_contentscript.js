//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-24

define(['jquery', 'logger', 'viking', 'html_utils', 'lib/path_utils', 'controllers/toolbar_contentscript'],
function($, logger, viking, hu, pu, ari_toolbar) {
  "use strict";

  var mapper = {};

  var buttons = [],
      url = window.location.href,
      host = viking.getHost(url),
      started = false,
      data;

  /* ********************************************************** */
  /*                        Initialisation                      */
  /* ********************************************************** */

  chrome.extension.onMessage.addListener(function(msg, sender) {
    if (sender.id !== chrome.runtime.id)
      return;

    if (msg.action === 'initialCrawl' || msg.action === 'updateCrawl') {
      updateFieldMatching();
    } else if (msg.action === 'recrawl') {
      chrome.storage.local.get('mappings', function(hash) {
        data = hash.mappings[url].data;
        rematch();
      });
    }
  });

  mapper.start = function() {
    if (started)
      return;
    started = true;
    chrome.storage.local.get('mappings', function(hash) {
      data = hash.mappings[url].data;
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
    viking.merge(map, data, host);

    chrome.storage.local.get('mappings', function(hash) {
      hash.mappings[url].data = data;
      chrome.storage.local.set(hash);
    });

    rematch();
  };

  function rematch() {
    chrome.extension.sendMessage({action: "crawlPage", url: url, mapping: viking.buildMapping(url, data), kind: 'update'});
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

  return mapper;
});