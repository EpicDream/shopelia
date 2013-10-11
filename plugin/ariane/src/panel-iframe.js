
require(['logger', 'jquery', 'jquery-ui', 'jquery-mobile'], function(logger, $) {
  "use strict";

  logger.level = logger.ALL;

  var url = document.referrer,
      hostsSelect,
      fieldsList,
      newFieldInput,
      currentField,
      pathsList,
      newPathInput;

  function onHostChange() {
    chrome.storage.local.get('mappings', function(hash) {
      var host = hostsSelect.val(),
          mapping = hash.mappings[url].data.viking[host],
          field;

      fieldsList.html("");
      for (field in mapping)
        $('<li><a href="#">'+field+'</a></li>').appendTo(fieldsList);
      fieldsList.listview('refresh');
      fieldsList.find("li").click(onFieldSelected);
    });
  }

  function onFieldSelected(event) {
    chrome.storage.local.get(['mappings', 'crawlings'], function(hash) {
      var host = hostsSelect.val(),
          field = event.target.innerText,
          paths = hash.mappings[url].data.viking[host][field].path || [],
          i;
      currentField.val(field);
      pathsList.html("");
      for (i in paths) {
        var li = $('<li>');
        li.append($('<label for="path'+i+'">Path '+i+' :</label>').hide());
        li.append($('<input type="text" id="path'+i+'" />').val(paths[i]));
        pathsList.append(li);
      }
      pathsList.listview('refresh').find("input").textinput();
      pathsResult.innerText = (hash.crawlings[url].update || hash.crawlings[url].initial)[field] || "Nothing found. :-(";
      pathsResult.title = pathsResult.innerText;
      if (pathsResult.innerText.length > 200)
        pathsResult.innerText = pathsResult.innerText.slice(0, 200) + "...";
      $.mobile.changePage('#pathsPage');
    });
  }

  function onNewFieldAdd(event) {
    var newField = newFieldInput.val();
    logger.debug("New field :", newField, "!");
    newFieldInput.val("");

    $('<li><a href="#">'+newField+'</a></li>').appendTo(fieldsList).click(onFieldSelected);
    fieldsList.listview('refresh');

    chrome.storage.local.get(['mappings', 'crawlings'], function(hash) {
      var host = hostsSelect.val();
      hash.mappings[url].data.viking[host][newField] = {path: []};
      chrome.storage.local.set(hash);
    });

    return false;
  }

  function onNewPathAdd(event) {
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
  }

  function onPathOkBtnClicked(event) {
    if (newPathInput.val() !== "")
      if (! confirm("Il y a un nouveau path prêt à être ajouté : êtes vous sur de vouloir continuer ?")) {
        event.preventDefault();
        return false;
      }

    var paths = pathsList.find("input").toArray().map(function(e) {return e.value;});
    chrome.storage.local.get(['mappings'], function(hash) {
      var host = hostsSelect.val(),
          field = currentField.val();
      hash.mappings[url].data.viking[host][field].path = paths;
      chrome.storage.local.set(hash);
      // chrome.extension.sendMessage({action: "crawlPage", url: url, mapping: mapping, kind: 'update'});
    });
  }

  $(document).ready(function() {
    $("div[data-role='page']").page();
    hostsSelect = $("#hosts").change(onHostChange);
    fieldsList = $("#fieldsList").listview();
    newFieldInput = $("#newFieldInput");
    newFieldInput.parents("form").on("submit", onNewFieldAdd);
    currentField = $("#currentField");
    pathsList = $("#pathsList").listview();
    newPathInput = $("#newPathInput");
    newPathInput.parents("form").on("submit", onNewPathAdd);
    $(pathOkBtn).click(onPathOkBtnClicked);


    chrome.storage.local.get('mappings', function(hash) {
      var hosts = Object.keys(hash.mappings[url].data.viking),
          i;
      for (i in hosts)
        $("<option>").val(hosts[i]).text(hosts[i]).appendTo(hostsSelect).trigger('create');
      hostsSelect.val("default").change();
    });
  });
});
