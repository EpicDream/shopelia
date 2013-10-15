
require(['logger', 'jquery', 'jquery-ui', 'jquery-mobile'], function(logger, $) {
  "use strict";

  logger.level = logger.ALL;

  window.panel = {};

  var url = document.referrer,
      hostsSelect,
      fieldsList,
      newFieldInput,
      currentField,
      pathsList,
      newPathInput;

  chrome.extension.onMessage.addListener(function(msg, sender) {
    if (msg.action === 'initialCrawl' || msg.action === 'updateCrawl') {
      if ($.mobile.activePage.attr("id") === 'pathsPage')
        panel.onFieldSelected();
      else
        panel.onHostChange();
    } else if (msg.action === 'setField')
      panel.onFieldSelected({field: msg.field});
  });

  panel.onHostChange = function() {
    chrome.storage.local.get(['mappings', 'crawlings'], function(hash) {
      var host = hostsSelect.val(),
          mapping = hash.mappings[url].data.viking[host],
          crawlRes = hash.crawlings[url].update || hash.crawlings[url].initial || {},
          field;

      fieldsList.html("");
      for (field in mapping)
        $('<li>').append($('<a href="#">').addClass(crawlRes[field] ? 'present' : 'absent').text(field)).appendTo(fieldsList);
      fieldsList.listview('refresh');
      fieldsList.find("li a").click(panel.onFieldSelected);
    });
  };

  panel.onFieldSelected = function(event) {
    var field;
    if (! event) {
      field = currentField.val();
    } else if (event.field) {
      field = event.field;
    } else if (event.currentTarget) {
      field = event.currentTarget.innerText;
    } else if (event.target) {
      field = event.target.innerText;
    }

    if (! field)
      return $.mobile.changePage('#fieldsPage');

    chrome.storage.local.get(['mappings', 'crawlings'], function(hash) {
      var host = hostsSelect.val(),
          mapping = hash.mappings[url].data.viking[host],
          paths = mapping[field].path || [],
          i;
      if (typeof paths === 'string')
        paths = [paths];
      currentField.val(field);
      fieldName.innerText = field;

      // RESULT
      pathsResult.value = (hash.crawlings[url].update || hash.crawlings[url].initial || {})[field] || "Nothing found. :-(";
      $(pathsResult).attr("title", pathsResult.value);
      if (pathsResult.value.length > 200)
        pathsResult.value = pathsResult.value.slice(0, 200) + "...";
      $(pathsResult).css('height', 'auto');

      // LABEL
      if (field.search(/^option/) !== -1) {
        $(optionLabel).val(mapping[field].label).parent().show().prev().show();
      } else
        $(optionLabel).val('').parent().hide().prev().hide();

      // PATH LIST
      pathsList.html("");
      for (i in paths) {
        var li = $('<li>');
        li.append($('<label for="path'+i+'">Path '+i+' :</label>').hide());
        li.append($('<input type="text" id="path'+i+'" />').val(paths[i]));
        var buttonGroup = $('<div data-role="controlgroup" data-type="horizontal" data-mini="true">');

        var searchBtn = $('<a data-role="button" data-icon="search" data-iconpos="notext" title="Search">Search</a>');
        searchBtn.addClass('ui-disabled');
        searchBtn.click(panel.onSearchBtnClicked);
        buttonGroup.append(searchBtn);
        var deleteBtn = $('<a data-role="button" data-icon="delete" data-iconpos="notext" title="Delete">Delete</a>');
        deleteBtn.click(panel.onDeleteBtnClicked);
        buttonGroup.append(deleteBtn);

        li.append(buttonGroup);
        pathsList.append(li);
        li.trigger('create');
      }
      pathsList.listview('refresh').find("input").textinput();

      $.mobile.changePage('#pathsPage');
    });
  };

  panel.onNewFieldAdd = function(event) {
    var newField = newFieldInput.val();
    logger.debug("New field :", newField, "!");
    newFieldInput.val("");

    $('<li><a href="#">'+newField+'</a></li>').appendTo(fieldsList).click(panel.onFieldSelected);
    fieldsList.listview('refresh');

    chrome.storage.local.get(['mappings', 'crawlings'], function(hash) {
      var host = hostsSelect.val();
      hash.mappings[url].data.viking[host][newField] = {path: []};
      chrome.storage.local.set(hash);
    });

    return false;
  };

  panel.onSearchBtnClicked = function(event) {
    logger.debug('Search "'+$(event.target).parentsUntil("ul", "li").find("input").val()+'"');
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

    $('<li>').append($('<input type="text" />').val(newPath)).appendTo(pathsList).trigger('create');
    pathsList.listview('refresh');

    chrome.storage.local.get(['mappings', 'crawlings'], function(hash) {
      var host = hostsSelect.val(),
          field = currentField.val();
      hash.mappings[url].data.viking[host][field].path.push(newPath);
      chrome.storage.local.set(hash);
    });

    return false;
  };

  panel.onPathOkBtnClicked = function(event) {
    if (newPathInput.val() !== "")
      if (! confirm("Il y a un nouveau path prêt à être ajouté : êtes vous sur de vouloir continuer ?")) {
        event.preventDefault();
        return false;
      }

    var paths = pathsList.find("input").toArray().map(function(e) {return e.value;});
    chrome.storage.local.get(['mappings'], function(hash) {
      var host = hostsSelect.val(),
          field = currentField.val(),
          mapping = hash.mappings[url].data.viking[host][field];
      mapping.path = paths;
      if (field.search(/^option/) !== -1)
        mapping.label = optionLabel.value;
      console.log("For '"+field+"', value='"+optionLabel.value+"', and final=", hash.mappings[url].data.viking[host][field].label);
      chrome.storage.local.set(hash);
      // chrome.extension.sendMessage({action: "crawlPage", url: url, mapping: mapping, kind: 'update'});
    });
  };

  $(document).ready(function() {
    $("div[data-role='page']").page();
    hostsSelect = $("#hosts").change(panel.onHostChange);
    fieldsList = $("#fieldsList").listview();
    newFieldInput = $("#newFieldInput");
    newFieldInput.parents("form").on("submit", panel.onNewFieldAdd);
    currentField = $("#currentField");
    pathsList = $("#pathsList").listview().sortable({ delay: 20, distance: 10, axis: "y", containment: "parent" }).on("sortupdate", panel.onPathSorted);
    newPathInput = $("#newPathInput");
    newPathInput.parents("form").on("submit", panel.onNewPathAdd);
    $(pathOkBtn).click(panel.onPathOkBtnClicked);


    chrome.storage.local.get('mappings', function(hash) {
      var hosts = Object.keys(hash.mappings[url].data.viking),
          i;
      for (i in hosts)
        $("<option>").val(hosts[i]).text(hosts[i]).appendTo(hostsSelect).trigger('create');
      hostsSelect.val("default").change();
    });
  });
});
