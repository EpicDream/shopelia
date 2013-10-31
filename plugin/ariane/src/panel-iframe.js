
require(['logger', 'jquery', 'jquery-ui', 'jquery-mobile'], function(logger, $) {
  "use strict";

  logger.level = logger.ALL;

  window.panel = {};

  var cUrl = window.top.location.href, // current url
      cHost ='', // current host
      cMapping = {}, // current mapping
      cCrawling = {}, // current crawling
      cField = '', // current field
      cConsistency = {}, // current consistency
      cPathsBackup = [],
      hostsSelect,
      fieldsList,
      newFieldInput,
      consistencyResult,
      pathsList,
      newPathInput;

  chrome.extension.onMessage.addListener(function(msg, sender) {
    if (msg.action === 'initialCrawl' || msg.action === 'updateCrawl') {
      chrome.storage.local.get(['crawlings', 'mappings'], function(hash) {
        cCrawling = hash.crawlings[cUrl].update || hash.crawlings[cUrl].initial || {};
        cMapping = hash.mappings[cUrl].data.viking[cHost];
        if ($.mobile.activePage.attr("id") === 'pathsPage') {
          panel.updateResult();
          panel.updatePathsList();
        }
        panel.updateFieldsMatch();
      });
    } else if (msg.action === 'setField') {
      panel.loadField(msg.field);
    } else if (msg.action === 'updateConsistency') {
      cConsistency = msg.results;
      panel.updateFieldsConsistency();
      panel.updateConsistency();
    }
  });

  panel.onHostChange = function() {
    cHost = hostsSelect.val();
    chrome.storage.local.get(['mappings'], function(hash) {
      cMapping = hash.mappings[cUrl].data.viking[cHost];
      fieldsList.html("");
      var fields = Object.keys(cMapping).sort();
      for (var i = 0; i < fields.length; i++)
        $('<li>').append($('<a href="#">').text(fields[i])).appendTo(fieldsList);
      fieldsList.listview('refresh');
      fieldsList.find("li a").click(panel.onFieldSelected);
      panel.updateFieldsMatch();
    });
  };

  panel.updateFieldsMatch = function() {
    fieldsList.find("li a").each(function() {
      if (cCrawling[this.innerText])
        this.classList.add('present');
      else
        this.classList.remove('present');
    });
  };

  panel.onFieldSelected = function(event) {
    var field  = event.currentTarget.innerText.trim();
    chrome.extension.sendMessage({action: 'setField', field: field});
  };

  panel.loadField = function(field) {
    cField = field;
    if (! cField)
      return $.mobile.changePage('#fieldsPage');

    chrome.storage.local.get(['mappings'], function(hash) {
      cMapping = hash.mappings[cUrl].data.viking[cHost];
      fieldName.innerText = cField;
      if (! cMapping[field]) {
        cMapping[field] = {paths: []};
        chrome.storage.local.set(hash);
        $('<li>').append($('<a href="#">').text(field).click(panel.onFieldSelected)).appendTo(fieldsList);
        fieldsList.listview('refresh');
        panel.updateFieldsMatch();
      }

      // RESULT
      panel.updateResult();

      // LABEL
      if (cField.search(/^option/) !== -1) {
        $(optionLabel).val(cMapping[cField].label).parent().show().prev().show();
      } else
        $(optionLabel).val('').parent().hide().prev().hide();

      // CONSISTENCY
      panel.updateConsistency();

      // PATH LIST
      cPathsBackup = cMapping[field].paths.slice();
      panel.updatePathsList();

      $.mobile.changePage('#pathsPage');
    });
  };

  panel.updateResult = function() {
    pathsResult.value = cCrawling[cField] || "Nothing found. :-(";
    pathsResult.title = pathsResult.value;
    if (pathsResult.value.length > 200)
      pathsResult.value = pathsResult.value.slice(0, 200) + "...";
    pathsResult.style.height = 'auto';
  };

  panel.updateFieldsConsistency = function () {
    fieldsList.find("li a").each(function() {
      if (cConsistency[this.innerText])
        this.classList.add('inconstistent');
      else
        this.classList.remove('inconstistent');
    });
  };

  panel.updateConsistency = function() {
    if (cConsistency[cField])
      consistencyResult.html(cConsistency[cField].map(function(e) {
        var res = "<b>Url :</b> " + e.url + "\n";
        res += "<b>Waited :</b> '" + e.old + "'\n";
        res += "<b>Crawled :</b> '" + e.new + "'\n";
        return res;
      }).join("\n\n")).show().prev().show();
    else
      consistencyResult.text('').hide().prev().hide();
  };

  panel.addPathToList = function(path) {
    var li = $('<li>'),
        i = pathsList[0].children.length;
    li.append($('<label for="path'+i+'">Path '+i+' :</label>').hide());
    var input = $('<input type="text" id="path'+i+'" />').val(path);
    li.append(input);
    var buttonGroup = $('<div data-role="controlgroup" data-type="horizontal" data-mini="true">');

    var searchBtn = $('<a data-role="button" data-icon="search" data-iconpos="notext" title="Search">Search</a>');
    searchBtn.click(panel.onSearchBtnClicked);
    buttonGroup.append(searchBtn);
    var deleteBtn = $('<a data-role="button" data-icon="delete" data-iconpos="notext" title="Delete">Delete</a>');
    deleteBtn.click(panel.onDeleteBtnClicked);
    buttonGroup.append(deleteBtn);

    li.append(buttonGroup);
    pathsList.append(li);
    li.trigger('create');
    if (panel.getMatchedElements(path).length > 0)
      input.parent().addClass('found');
    return li;
  };

  panel.updatePathsList = function() {
    var paths = cMapping[cField] && cMapping[cField].paths || [],
        i;
    pathsList.html("");
    for (i in paths)
      panel.addPathToList(paths[i]);
    pathsList.listview('refresh').find("input").textinput();
  };

  panel.onNewFieldAdd = function() {
    var newField = newFieldInput.val().trim().replace(/\W/, '').toLowerCase();
    logger.debug("New field :", newField, "!");
    newFieldInput.val("");

    $('<li>').append($('<a href="#">'+newField+'</a>').click(panel.onFieldSelected)).appendTo(fieldsList);
    fieldsList.listview('refresh');

    chrome.storage.local.get(['mappings'], function(hash) {
      hash.mappings[cUrl].data.viking[cHost][newField] = {paths: []};
      chrome.storage.local.set(hash);
    });

    return false; // To prevent form submission.
  };

  panel.getMatchedElements = function(path) {
    return $(path, window.parent.document);
  };

  // Highlight elements
  panel.onSearchBtnClicked = function(event) {
    var input = $(event.currentTarget).parentsUntil("ul", "li").find("input");
    var path = input.val();
    logger.debug('Search "'+path+'"');
    if (panel.getMatchedElements(path).length > 0) {
      input.parent().addClass('found');
      panel.getMatchedElements(path).effect("highlight", {color: "#00cc00" }, "slow");
    } else {
      input.parent().removeClass('found');
    }
  };

  panel.onDeleteBtnClicked = function(event) {
    if (! confirm("Êtes vous sûr de vouloir supprimer ce path ?"))
      return;
    logger.debug('Delete "'+$(event.target).parentsUntil("ul", "li").find("input").val()+'"');
    $(event.target).parentsUntil("ul", "li").remove();
    pathsList.listview('refresh');
  };

  panel.onPathSorted = function(event, ui) {
    logger.debug('Sort "'+ui.item.find("input").val()+'"');
    pathsList.listview('refresh');
  };

  panel.onNewPathAdd = function(event) {
    var newPath = newPathInput.val();
    logger.debug("New path :", newPath, "!");
    newPathInput.val("");

    panel.addPathToList(newPath);
    pathsList.listview('refresh');

    chrome.storage.local.get(['mappings'], function(hash) {
      hash.mappings[cUrl].data.viking[cHost][cField].paths.push(newPath);
      chrome.storage.local.set(hash);
      chrome.extension.sendMessage({action: 'recrawl'});
    });

    return false; // To prevent form submission.
  };

  panel.savePathsPage = function () {
    var paths = pathsList.find("input").toArray().map(function(e) {return e.value;});
    cMapping[cField].paths = paths;
    if (cField.search(/^option/) !== -1)
      cMapping[cField].label = optionLabel.value;
  };

  panel.onPathOkBtnClicked = function(event) {
    if (newPathInput.val() !== "")
      if (! confirm("Il y a un nouveau path prêt à être ajouté : êtes vous sur de vouloir continuer ?")) {
        event.preventDefault();
        return false;
      }

    panel.savePathsPage();
    chrome.storage.local.get(['mappings'], function(hash) {
      hash.mappings[cUrl].data.viking[cHost] = cMapping;
      chrome.storage.local.set(hash);
      chrome.extension.sendMessage({action: 'recrawl'});
      chrome.extension.sendMessage({action: 'setField', field: ''});
    });
  };

  panel.resetPaths = function () {
    var field = cField;
    chrome.storage.local.get(['mappings'], function(hash) {
      hash.mappings[cUrl].data.viking[cHost][field].paths = cPathsBackup;
      chrome.storage.local.set(hash);
    });
  };

  panel.onPathCancelBtnClicked = function () {
    panel.resetPaths();
    chrome.extension.sendMessage({action: 'setField', field: ''});
  };

  $(document).ready(function() {
    $("div[data-role='page']").page();
    hostsSelect = $("#hosts").change(panel.onHostChange);
    fieldsList = $("#fieldsList").listview();
    newFieldInput = $("#newFieldInput");
    newFieldInput.parents("form").on("submit", panel.onNewFieldAdd);
    consistencyResult = $("#consistencyResult").textinput();
    pathsList = $("#pathsList").listview().sortable({
      delay: 20, distance: 10, axis: "y"
    }).on("sortupdate", panel.onPathSorted);
    newPathInput = $("#newPathInput");
    newPathInput.parents("form").on("submit", panel.onNewPathAdd);
    $(pathCancelBtn).click(panel.onPathCancelBtnClicked);
    $(pathOkBtn).click(panel.onPathOkBtnClicked);

    chrome.storage.local.get(['mappings', 'crawlings'], function(hash) {
      cCrawling = hash.crawlings[cUrl].update || hash.crawlings[cUrl].initial || {};
      var hosts = Object.keys(hash.mappings[cUrl].data.viking),
          i;
      for (i in hosts)
        $("<option>").val(hosts[i]).text(hosts[i]).appendTo(hostsSelect).trigger('create');
      hostsSelect.val("default").change();
    });
  });
});
