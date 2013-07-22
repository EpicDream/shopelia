
function loadHumanis() {
  // Create DIV
  var div = document.createElement('div');
  div.id = "humanisDiv"
  document.documentElement.appendChild(div);
  jHumanis = $(div);

  // Import HTML into DIV
  jHumanis.hide().load(chrome.runtime.getURL('views/toolbar.html'), build);

  // Import CSS
  css_link = document.createElement('link');
  css_link.rel = "stylesheet";
  css_link.href = chrome.runtime.getURL("assets/smoothness/jquery-ui-1.10.3.custom.min.css");
};

function build() {
  // Init global variables
  jToolbar = jHumanis.find("#toolbar");
  jStep = jToolbar.find("#step");
  jButtons = jToolbar.find("span:not(#ctrl) button");

  // Initialize jQuery Elements
  jToolbar.find("button").button();
  jToolbar.find(".buttonset").buttonset();
  jToolbar.find("#abort").button({
    text: false,
    icons: {primary: "ui-icon-cancel"}
  });
  jToolbar.find("#next").button({
    text: false,
    icons: {primary: "ui-icon-circle-arrow-e"}
  }).addClass("ui-corner-right");
  jToolbar.find("#finish").button({
    text: false,
    icons: {primary: "ui-icon-circle-check"}
  }).hide();

  // Link events
  jToolbar.find("#next").click(onNext);
  jToolbar.find("#finish").click(onFinished);
  jToolbar.find("#abort").click(onAborted);
  jStep.change(onStepChanged);
  jButtons.click(onButtonClicked);
}

/* ********************************************************** */
/*                          On Event                          */
/* ********************************************************** */

function onStepChanged(event) {
  field_for_step = {
    account_creation: "#account, #user",
    logout: "",
    login: "#account",
    empty_cart: "",
    extract: "#prod",
    add_product: "",
    finalize: "#user, #tot",
    payment: "#card"
  };

  jToolbar.find(".buttonset").filter(":not(#ctrl)").hide();
  jToolbar.find(field_for_step[jStep.val()]).show();
  if (jStep.val() == "payment" || jStep.val() == "extract") {
    jToolbar.find("#next").hide();
    jToolbar.find("#finish").show();
  } else {
    jToolbar.find("#next").show();
    jToolbar.find("#finish").hide();
  }
};

function onNext() {
  jStep[0].selectedIndex += 1;
  // Par défaut, on skip extract.
  if (jStep.find("option:selected").prop("disabled"))
    jStep[0].selectedIndex += 1;
  jStep.change();
};

function onButtonClicked(event) {
  jButtons.filter(".current-field").add(event.currentTarget).toggleClass("current-field");
};

function onAborted() {
  res = prompt("Pour quelle raison annule-t-on ?");
  if (!res)
    return;
  chrome.extension.sendMessage({abort: res});
};

function onFinished() {
  chrome.extension.sendMessage('finish');
};

/* ********************************************************** */
/*                           Utilities                        */
/* ********************************************************** */

function startHumanis(crawl_mode) {
  if (crawl_mode)
    jStep.val("extract").prop("disabled", true);
  document.head.appendChild(css_link);
  $(document.body).addClass("ariane");
  jHumanis.show();
  onStepChanged();
};

function getCurrentFieldId() {
  var fieldId = (jToolbar.find("button.current-field:visible").attr("id") || "").replace(/product-/, '');
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

loadHumanis();
