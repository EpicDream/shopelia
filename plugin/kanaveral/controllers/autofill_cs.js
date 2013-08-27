//
// Author : Vincent RENAUDINEAU

define(['jquery', 'toolbar', 'order', 'html_utils'], function($, tb, od, hu) {
  "use strict";

  var that = {};

  //
  function onInputChange(event) {
    var t = ["user-gender", "user-birthdate-day", "user-birthdate-month", "user-birthdate-year", "user-birthdate-full",
             "user-address-city", "user-address-country", "order-credentials-exp_month", "order-credentials-exp_year"];
    var key = tb.currentDataId();
    if (! key)
      key = "other";
    var context = hu.getElementContext(event.currentTarget);
    var tagName = event.currentTarget.tagName;
    var action = "fill"; // default, for textarea and all others input types.
    if (tagName == "SELECT") action = "select";
    else {
      var type = event.currentTarget.getAttribute("type");
      if (type == "checkbox") action = event.currentTarget.checked ? "tick" : "untick";
      else if (type == "radio") action = "click_on_radio";
    }
    chrome.extension.sendMessage({dest: 'autofill', action: 'set', event: {step: tb.currentStep(), action: action, key: key, context: context}});
  };

  function onEnd() {
    chrome.extension.sendMessage({dest: 'autofill', action: 'finish'});
  };

  // Try to autofill inputs present on the page, based on current step.
  that.autofill = function(step) {
    var autofill = that.autofill;
    if (! autofill || ! autofill[step] || ! step)
      return;
    for (var i in autofill[step]) {
      var contexts = autofill[step][i];
      for (var j in contexts) {
        var context = contexts[j];

        var elems = $(context.css);
        if (elems.length != 1)
          elems = $x(context.xpath);
        if (elems.length != 1)
          elems = $(context.fullCSS);
        if (elems.length != 1)
          elems = $x(context.fullXPath);
        if (elems.length != 1) {
          console.warn("Cannot autofill for", elems.length, "elements !");
          $e = {context: context, elems: elems};
          continue;
        }

        var tag = elems[0].tagName;
        var type = elems[0].getAttribute("type");
        if (tag == "SELECT")
          elems[0].value = context.attrs.value;
        else if (tag == "INPUT" && (type == "radio" || type == "checkbox")) {
          elems[0].checked = context.attrs.checked;
        } else if (tag == "INPUT") {
          elems[0].value = od.orderValueHash[i];
        } else {
          console.error("Cannot autofill a", elems[0].tagName, "element !");
          $e = elems[0];
          break;
        }
      }
    }
  };

  chrome.extension.sendMessage({dest: 'autofill', action: 'get'}, function(autofill) {
    console.debug("Autofill received", autofill);
    that.autofill = autofill;
    $("body input, body select").change(onInputChange);
    $([tb.finishElem, tb.abortElem]).click(onEnd);
  });

  return that;
});