
define('toolbar', ['jquery', 'logger'], function($, logger) {

  var toolbar = {},
      jToolbar,
      jStep,
      jButtons;

function loadAriane() {
  // Create DIV
  var div = document.createElement('div');
  div.id = "arianeDiv";
  document.documentElement.appendChild(div);
  jAriane = $(div);

  // Import HTML into DIV
  jAriane.hide().load(chrome.runtime.getURL('views/toolbar.html'), build);

  // Import CSS
  css_link = document.createElement('link');
  css_link.rel = "stylesheet";
  css_link.href = chrome.runtime.getURL("assets/main.css");

}

function build() {
  // Init global variables
  jToolbar = jAriane.find("#ariane-toolbar");
  jStep = jToolbar.find("#ariane-step");
  jButtons = jToolbar.find("span:not(#ariane-ctrl) button");

  // Initialize jQuery Elements
  jToolbar.find("button").button();
  jToolbar.find(".buttonset").buttonset();
  jToolbar.find(".ari-abort").button({
    text: false,
    icons: {primary: "ui-icon-cancel"}
  });
  jToolbar.find(".ari.-next").button({
    text: false,
    icons: {primary: "ui-icon-circle-arrow-e"}
  }).addClass("ui-corner-right");
  jToolbar.find(".ari-finish").button({
    text: false,
    icons: {primary: "ui-icon-circle-check"}
  }).hide();

  // Link events
  jToolbar.find(".ari-next").click(onNext);
  jToolbar.find(".ari-finish").click(onFinished);
  jToolbar.find(".ari-abort").click(onAborted);
  jStep.change(onStepChanged);
  jButtons.click(onButtonClicked);

  //
  toolbar.toolbarElem = jToolbar[0];
  toolbar.stepElem = jStep[0];
  toolbar.buttons = jButtons.toArray();
}

  loadAriane();

/* ********************************************************** */
/*                          On Event                          */
/* ********************************************************** */

function onStepChanged(event) {
  field_for_step = {
    account_creation: "#ariane-account, #ariane-user",
    logout: "",
    login: "#ariane-account",
    empty_cart: "",
    extract: "#ariane-prod",
    add_product: "",
    finalize: "#ariane-user, #ariane-tot",
    payment: "#ariane-card"
  };

  jToolbar.find(".buttonset").filter(":not(#ariane-ctrl)").hide();
  jToolbar.find(field_for_step[jStep.val()]).show();
  if (jStep.val() == "payment" || jStep.val() == "extract") {
    jToolbar.find(".ari-next").hide();
    jToolbar.find(".ari-finish").show();
  } else {
    jToolbar.find(".ari-next").show();
    jToolbar.find(".ari-finish").hide();
  }
}

function onNext() {
  jStep[0].selectedIndex += 1;
  // Par défaut, on skip extract.
  if (jStep.find("option:selected").prop("disabled"))
    jStep[0].selectedIndex += 1;
  jStep.change();
}

function onButtonClicked(event) {
  jButtons.filter(".current-field").add(event.currentTarget).toggleClass("current-field");
}

function onAborted() {
  res = prompt("Pour quelle raison annule-t-on ?");
  if (!res)
    return;
  chrome.extension.sendMessage({action: 'abort', reason: res});
}

function onFinished() {
  chrome.extension.sendMessage({action: 'finish'});
}

/* ********************************************************** */
/*                           Utilities                        */
/* ********************************************************** */

toolbar.startAriane = function(crawl_mode) {
  if (crawl_mode)
    jStep.val("extract").prop("disabled", true);
  $(document.body).addClass("ariane");
  document.head.appendChild(css_link);
  jAriane.show();
  onStepChanged();
};

toolbar.getCurrentFieldId = function() {
  var fieldId = (jToolbar.find("button.current-field:visible").attr("id") || "").replace(/ariane-/, '').replace(/product-/, '');
  if (! fieldId)
    fieldId = "other";
  return fieldId;
};

/* ********************************************************** */
/*                        Initialisation                      */
/* ********************************************************** */

chrome.extension.onMessage.addListener(function(msg, sender) {
  if (sender.id != chrome.runtime.id || msg != "next-step")
    return;

  var buttons = jButtons.filter(":visible");
  var e = buttons.filter(".current-field");
  var idx = buttons.index(e);
  if (! e)
    buttons.first().addClass("current-field");
  else if (idx+1 < buttons.length) {
    e.removeClass("current-field");
    buttons.eq(idx+1).addClass("current-field");
  } else {
    e.removeClass("current-field");
  }
});
  
  return toolbar;
});