//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-24

define(['jquery', 'chrome_logger', 'html_utils', 'crawler', 'mapping', 'lib/path_utils', 'controllers/toolbar_contentscript', 'arconf'],
function($, logger, hu, Crawler, Mapping, pu, ari_toolbar) {
  "use strict";

  logger.level = logger[arconf.log_level];

  var mapper = {};

  var buttons = [],
      url = window.location.href,
      host = Mapping.getHost(url),
      started = false,
      mapping;

  /* ********************************************************** */
  /*                        Initialisation                      */
  /* ********************************************************** */

  chrome.extension.onMessage.addListener(function(msg, sender) {
    if (sender.id !== chrome.runtime.id)
      return;

    if (msg.action === 'initialCrawl' || msg.action === 'updateCrawl') {
      updateFieldsMatching(msg);
      mapper.savePage();
    } else if (msg.action === 'recrawl') {
      chrome.storage.local.get('mappings', function(hash) {
        if (! hash.mappings[url])
          return logger.warn('Cannot find '+url+' in\n'+Object.keys(hash.crawlings).join('\n'));
        mapping = new Mapping(hash.mappings[url], url);
        rematch(msg.field);
      });
    } else if (msg.action === 'updateConsistency') {
      updateFieldsConsitency(msg.results);
    }
  });

  mapper.start = function() {
    if (started)
      return;
    started = true;
    chrome.storage.local.get('mappings', function(hash) {
      if (! hash.mappings[url])
        return logger.warn('Cannot find '+url+' in\n'+Object.keys(hash.crawlings).join('\n'));
      mapping = new Mapping(hash.mappings[url], url);
      mapper.savePage();
      mapper.init();
    });
  };

  mapper.init = function() {
    buttons = $(ari_toolbar.toolbarElem).find("button[id^='ariane-product-']");
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
    updateFieldsMatching();
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

    mapping.addPath(fieldId, path);

    chrome.storage.local.get('mappings', function(hash) {
      hash.mappings[url] = mapping.toObject();
      chrome.storage.local.set(hash);

      rematch(fieldId);
    });
  };

  mapper.savePage = function () {
    chrome.storage.local.get(['mappings'], function (hash) {
      mapping.saveCurrentPage();
      hash.mappings[url] = mapping.toObject();
      chrome.storage.local.set(hash);
    });
  };

  function rematch(field) {
    var map = mapping.currentMap,
      strategy = (field !== undefined && field.search(/option\d/i) === -1 ? 'superFast' : 'fast'),
      results = mapping.checkConsistency();
    buttons.attr('title', ''); // reset title
    updatePageResult();
    chrome.extension.sendMessage({action: "updateConsistency", url: url, results: results});
    chrome.extension.sendMessage({action: "crawlPage", url: url, mapping: map, kind: 'update', strategy: strategy});
  }

  function updateFieldsMatching(options) {
    options = options || {};
    chrome.storage.local.get('crawlings', function(hash) {
      var crawlResults = hash.crawlings[url].update || hash.crawlings[url].initial;
      if (! crawlResults)
        return;
      logger.info("Crawl results :", crawlResults);
      if (options.strategy === 'superFast') {
        var but = buttons.filter(":not([id*='option'])");
        logger.debug(but.length + ' buttons !');
        but.removeClass('mapped').addClass('missing');
      } else {
        logger.debug('Strategy == ' + crawlResults.strategy);
        buttons.removeClass('mapped').addClass('missing');
      }
      for (var key in crawlResults)
        if (crawlResults[key]) {
          var b = buttons.filter("#ariane-product-"+key);
          if (b.length === 0) {
            logger.warn("No button found with key = "+key);
            continue;
          }
          b.removeClass("missing").addClass("mapped");
          if (b[0].title) b[0].title += "\n";
          b[0].title += "Crawl result = '" + crawlResults[key] + "'\n";
        }
    });
  }

  function updatePageResult() {
    var page = mapping.getPage(url);
    page.results = Crawler.fastCrawl(mapping.currentMap, Mapping.page2doc(page));
    logger.debug("New page results =", page.results);
    chrome.storage.local.get(['mappings'], function (hash) {
      hash.mappings[url] = mapping.toObject();
      chrome.storage.local.set(hash);
    });
  }

  function updateFieldsConsitency(results) {
    var b, key;
    logger.info("Consistency results :", results);
    buttons.removeClass('inconstistent');
    for (key in results) {
      b = buttons.filter("#ariane-product-"+key);
      b.addClass("inconstistent");
      b[0].title += results[key].map(function(e) {return "\n" + e.msg + "\n";}).join('');
    }
  }


  return mapper;
});