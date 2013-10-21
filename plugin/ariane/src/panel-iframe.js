
require(['logger', 'jquery', 'jquery-ui', 'jquery-mobile'], function(logger, $) {
  "use strict";

  logger.level = logger.ALL;

  window.panel = {};

  var cUrl = document.referrer, // current url
      cHost ='', // current host
      cMapping = {}, // current mapping
      cCrawling = {}, // current crawling
      cField = '', // current field
      hostsSelect,
      fieldsList,
      newFieldInput,
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
        panel.updateFieldMatch();
      });
    } else if (msg.action === 'setField') {
      panel.loadField(msg.field);
    }
  });

  panel.onHostChange = function() {
    cHost = hostsSelect.val();
    chrome.storage.local.get(['mappings'], function(hash) {
      cMapping = hash.mappings[cUrl].data.viking[cHost];
      fieldsList.html("");
      for (var field in cMapping)
        $('<li>').append($('<a href="#">').text(field)).appendTo(fieldsList);
      fieldsList.listview('refresh');
      fieldsList.find("li a").click(panel.onFieldSelected);
      panel.updateFieldMatch();
    });
  };

  panel.updateFieldMatch = function() {
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

      // RESULT
      panel.updateResult();

      // LABEL
      if (cField.search(/^option/) !== -1) {
        $(optionLabel).val(cMapping[cField].label).parent().show().prev().show();
      } else
        $(optionLabel).val('').parent().hide().prev().hide();

      // PATH LIST
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
    var paths = cMapping[cField] && cMapping[cField].path || [],
        i;
    if (typeof paths === 'string')
      paths = [paths];
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
      hash.mappings[cUrl].data.viking[cHost][newField] = {path: []};
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
      hash.mappings[cUrl].data.viking[cHost][cField].path.push(newPath);
      chrome.storage.local.set(hash);
    });

    return false; // To prevent form submission.
  };

  panel.onPathOkBtnClicked = function(event) {
    if (newPathInput.val() !== "")
      if (! confirm("Il y a un nouveau path prêt à être ajouté : êtes vous sur de vouloir continuer ?")) {
        event.preventDefault();
        return false;
      }

    var paths = pathsList.find("input").toArray().map(function(e) {return e.value;});
    chrome.storage.local.get(['mappings'], function(hash) {
      var mapping = hash.mappings[cUrl].data.viking[cHost][cField];
      mapping.path = paths;
      if (cField.search(/^option/) !== -1)
        mapping.label = optionLabel.value;
      chrome.storage.local.set(hash);
      chrome.extension.sendMessage({action: 'recrawl'});
    });
  };

  panel.onBackBtnClicked = function() {
    chrome.extension.sendMessage({action: 'setField', field: ''});
  };

  $(document).ready(function() {
    $("div[data-role='page']").page();
    hostsSelect = $("#hosts").change(panel.onHostChange);
    fieldsList = $("#fieldsList").listview();
    newFieldInput = $("#newFieldInput");
    newFieldInput.parents("form").on("submit", panel.onNewFieldAdd);
    pathsList = $("#pathsList").listview().sortable({ delay: 20, distance: 10, axis: "y", containment: "parent" }).on("sortupdate", panel.onPathSorted);
    newPathInput = $("#newPathInput");
    newPathInput.parents("form").on("submit", panel.onNewPathAdd);
    $(pathOkBtn).click(panel.onPathOkBtnClicked);
    $(".backButton").click(panel.onBackBtnClicked);

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
