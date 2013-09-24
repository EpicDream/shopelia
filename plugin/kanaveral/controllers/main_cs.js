//
// Author : Vincent RENAUDINEAU

(function() {
"use strict";

requirejs.load = function(context, moduleName, url) {
  var xhr = new XMLHttpRequest();
  xhr.open("GET", chrome.extension.getURL(url) + '?r=' + (new Date()).getTime(), true);
  xhr.onreadystatechange = function(e) {
    if (xhr.readyState === 4 && xhr.status === 200) {
      eval(xhr.responseText);
      context.completeLoad(moduleName);
    }
  };
  xhr.send(null);
};

// Configure RequireJS
requirejs.config({
  baseUrl: 'lib',
  paths: {
    toolbar: '../controllers/toolbar_cs',
    order: '../controllers/order_cs',
    copy: '../controllers/copy_cs',
    autofill: '../controllers/autofill_cs',
    kanaveral: '../controllers/kanaveral_cs'
  },
  shim: {
      'jquery-ui': ['jquery'],
      'underscore': {
          exports: '_'
      }
  }
});

// Start the main app logic.
requirejs(['kanaveral', 'order', 'copy', 'autofill'], function() {
  console.log("Kanaveral toolbar loaded !");
});

})();