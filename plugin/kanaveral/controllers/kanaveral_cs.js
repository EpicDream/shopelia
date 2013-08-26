//
// Author : Vincent RENAUDINEAU

define(['jquery', 'toolbar'],
function($, tb, af) {
  "use strict";

  tb.create("kanaveral");

  var that = {state: {}},
      jToolbar = null,
      jButtons = null,
      jStep = null;

  function onTextSelection() {
    console.log("in onTextSelection");

    var selRange = window.getSelection();
    var fieldId = jButtons.filter(":visible.current-field.extractor").attr('data-id');
    if (selRange.rangeCount == 0 || ! fieldId)
      return;

    console.log(fieldId, selRange);

    var node = selRange.baseNode;
    if (node.nodeType == document.TEXT_NODE)
      node = node.parentNode;

    if (fieldId == "prodImg")
      var selection = _.map( $(node).find("img"), function(i) { return $(i).attr("src"); });
    else
      var selection = selRange.toString();

    if (selection.length == 0)
      return;

    // var context = hu.getElementContext(node);
    chrome.extension.sendMessage({dest: 'order', action: 'set_value', for: fieldId, with: selection});
  };

  function onStepChanged(event) {
    var val = jStep.val();
    that.state.currentStep = val;
    if (val == "add_product" || val == "finalize") {
      chrome.extension.sendMessage({dest: 'kanaveral', action: 'next_product'});
    } else {
      chrome.extension.sendMessage({dest: 'kanaveral', action: 'set', state: that.state});
    }
    // af.autofill();
  };

  function onAborted() {
    res = prompt("Pour quelle raison annule-t-on ?");
    if (!res)
      return;
    chrome.extension.sendMessage({dest: 'kanaveral', action: "finish", value: res});
  };

  function onFinished() {
    chrome.extension.sendMessage({dest: 'kanaveral', action: 'finish'});
  };

  tb.ready(function() {
    jToolbar = $(tb.root);
    jButtons = $(tb.buttonElems);
    jStep = $(tb.stepElem);

    jToolbar.find(".tb-finish").click(onFinished);
    jToolbar.find(".tb-abort").click(onAborted);

    chrome.extension.sendMessage({dest: 'kanaveral', action: 'get'}, function(state) {
      console.debug("State received", state);
      that.state = state;
      if (state.currentStep)
        jStep.val(state.currentStep).change();
      jStep.change(onStepChanged);
    
      $("body").bind("mouseup", onTextSelection);
    });
  });

  return that;
});
