//
// Author : Vincent RENAUDINEAU

define(['jquery', 'jquery-ui'], function($, jui) {
  "use strict";

  /* ********************************************************** */
  /*                       Private Methods                      */
  /* ********************************************************** */

  var jToolbar,
      jStep, jButtons, jControllers, jAbortBtn, jNextBtn, jFinishBtn,
      field_for_step = {
        account_creation: ".tb-account, .tb-user",
        logout: "",
        login: ".tb-account",
        empty_cart: "",
        extract: ".tb-product",
        add_product: "",
        finalize: ".tb-user, .tb-billing",
        payment: ".tb-credentials"
      },
      id;

  //
  function initialize() {
    // Build toolbar
    jToolbar.find("button").button();
    jToolbar.find(".buttonset").buttonset();
    // Controllers
    jControllers = jToolbar.find(".tb-ctrl button");
    that.contollerElems = $.makeArray(jControllers);
    // Abort button
    jAbortBtn = jControllers.filter(".tb-abort").button({
      text: false,
      icons: {primary: "ui-icon-cancel"}
    });
    that.abortElem = jAbortBtn[0];
    // Next button
    jNextBtn = jControllers.filter(".tb-next").button({
      text: false,
      icons: {primary: "ui-icon-circle-arrow-e"}
    }).addClass("ui-corner-right").click(that.nextStep);
    // Finish button
    jFinishBtn = jControllers.filter(".tb-finish").button({
      text: false,
      icons: {primary: "ui-icon-circle-check"}
    }).hide();
    that.finishElem = jFinishBtn[0];
    // All others buttons
    jButtons = jToolbar.find("span:not(.tb-ctrl) button").click(onButtonClicked);
    that.buttonElems = $.makeArray(jButtons);
    // Step select
    jStep = jToolbar.find(".tb-step").change(onStepChanged);
    that.stepElem = jStep[0];
    that.stepElem.selectIndex = 0;
    jStep.change();
    //
    initialized = true;
  };

  //
  function onStepChanged(event) {
    jButtons.parent().hide();
    jButtons.parent().filter( field_for_step[jStep.val()] ).show();
    if (jStep.val() == "payment") {
      jNextBtn.hide();
      jFinishBtn.filter(".tb-finish").show();
    } else {
      jNextBtn.filter(".tb-next").show();
      jFinishBtn.filter(".tb-finish").hide();
    }
  };

  // Toggle previous and current button.
  // If previous == current, juste toggle it.
  function onButtonClicked(event) {
    jButtons.filter(".current-field").add(event.currentTarget).toggleClass("current-field");
  };

  /* ********************************************************** */
  /*                        Public Methods                      */
  /* ********************************************************** */

  var that = {},
      initialized = false,
      created = false,
      onready = [];

  //
  that.create = function(ident) {
    if (ident) {
      // Prepare toolbar identifier.
      id = typeof ident == "string" && ident.search(/\b[\w-]+\b/) !== -1 ? ident : '';
      that.id = id;
      if (id) id += '-';
    }

    if (! initialized)
      return setTimeout(that.create, 100);

    // Update style with toolbar id.
    jToolbar.find("style").text(jToolbar.find("style").text().replace(/toolbarid-/g,id));

    jToolbar.attr("id", id+"toolbar");
    $(document.documentElement).prepend(jToolbar);

    // Add jQuery-UI CSS
    var link = $("<link>").attr("rel","stylesheet").attr("href", chrome.runtime.getURL("assets/smoothness/jquery-ui-1.10.3.custom.min.css"));
    $(document.head).append(link);

    // Call all listeners
    created = true;
    for (var i in onready)
      onready[i]();
  };

  //
  that.ready = function(listener) {
    if (created)
      listener();
    else
      onready.push(listener);
  };

  //
  that.nextStep = function() {
    if (jStep.val() != "payment")
      jStep[0].selectedIndex += 1;
    else if (jStep.val() == "payment")
      jStep[0].selectedIndex = -1;
    jStep.change();
  };

  //
  that.selectButton = function(arg) {
    jthat.find(arg).click();
  };
  //
  that.unselectCurrentButton = function() {
    jButtons.filter(".current-field").removeClass("current-field");
  };

  //
  that.setCrawlMode = function() {
    jStep.val("extract").prop("disabled", true);
    onStepChanged()
    jNextBtn.hide();
    jFinishBtn.show();
  };

  //
  that.currentDataId = function() {
    return jButtons.filter(".current-field").attr('data-id');
  };

  //
  that.currentStep = function() {
    return jStep.val();
  };

  // Create a div at html root.
  jToolbar = $("<div>").attr("id", "toolbar").addClass("ui-widget-header");
  jToolbar.load(chrome.runtime.getURL('views/toolbar.html'), initialize);
  that.root = jToolbar[0];

  chrome.extension.onMessage.addListener(function(msg, sender) {
    if (sender.id !== chrome.runtime.id || ! (typeof msg == 'object') || msg.dest != id )
      return;

    if (msg.action == "unselect-button")
      that.unselectCurrentButton();
    else if (msg == "next-step")
      that.nextStep();
  });

  return that;
});
