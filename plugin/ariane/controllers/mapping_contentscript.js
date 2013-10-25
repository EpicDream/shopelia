//
// Author : Vincent RENAUDINEAU
// Created : 2013-09-24

define(['jquery', 'logger', 'viking', 'html_utils', 'crawler', 'lib/path_utils', 'controllers/toolbar_contentscript'],
function($, logger, viking, hu, Crawler, pu, ari_toolbar) {
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
      updateFieldsMatching();
      mapper.savePage();
    } else if (msg.action === 'recrawl') {
      chrome.storage.local.get('mappings', function(hash) {
        data = hash.mappings[url].data;
        rematch();
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
      data = hash.mappings[url].data;
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

    var map = {};
    map[fieldId] = {path: path};
    viking.merge(map, data, host);

    chrome.storage.local.get('mappings', function(hash) {
      hash.mappings[url].data = data;
      chrome.storage.local.set(hash);

      rematch();
    });
  };

  mapper.savePage = function () {
    chrome.storage.local.get(['mappings', 'crawlings'], function (hash) {
      var data = hash.mappings[url].data,
        page;
      if (! data.pages)
        data.pages = {};
      if (! data.pages[url])
        data.pages[url] = viking.getPage(document);
      page = data.pages[url];
      if (! page.results)
        page.results = Crawler.fastCrawl(viking.buildMapping(url, data));
      chrome.storage.local.set(hash);
    });
  };

  function rematch() {
    var mapping = viking.buildMapping(url, data),
      results = mapper.checkConsistency(mapping);
    buttons.attr('title', ''); // reset title
    updatePageResult(mapping);
    chrome.extension.sendMessage({action: "updateConsistency", url: url, results: results});
    chrome.extension.sendMessage({action: "crawlPage", url: url, mapping: mapping, kind: 'update'});
  }

  function updateFieldsMatching() {
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
          if (b[0].title) b[0].title += "\n";
          b[0].title += "Crawl result = '" + crawlResults[key] + "'\n";
        }
    });
  }

  function updatePageResult(mapping) {
    chrome.storage.local.get(['mappings'], function (hash) {
      var page = hash.mappings[url].data.pages[url];
      page.results = Crawler.fastCrawl(mapping, viking.getDocument(page));
      logger.debug("New page results =", page.results);
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

  mapper.checkConsistency = function (mapping, field) {
    var pages = data.pages,
      fields = field ? [field] : Object.keys(mapping),
      results = {},
      page, pageUrl, oldResults, pageDoc, newResults, i;

    for (pageUrl in pages) {
      if (pageUrl === url) continue;
      page = pages[pageUrl];
      oldResults = page.results;
      pageDoc = viking.getDocument(page);
      newResults = Crawler.fastCrawl(mapping, pageDoc);
      for (i = fields.length - 1; i >= 0; i--) {
        field = fields[i];
        if (oldResults[field] != newResults[field]) {
          results[field] = results[field] || [];
          results[field].push({
            url: page.href,
            old: oldResults[field],
            new: newResults[field],
            msg: "On page '"+page.href+"',\n'" + newResults[field] + "' got, but\n'" + oldResults[field] + "' waited.",
          });
        }
      }
    }
    return results;
  };

  return mapper;
});