//
// Author : Vincent RENAUDINEAU

"use strict";

// Configure RequireJS
requirejs.config({
  baseUrl: '../lib',
  paths: {
    toolbar: '../controllers/toolbar_back',
    copy: '../controllers/copy_back',
    autofill: '../controllers/autofill_back',
    order: '../controllers/order_back',
    kanaveral: '../controllers/kanaveral_back'
  },
  shim: {
    order: {exports: 'korder'},
    autofill: {exports: 'kautofill'}
  }
});

// Start the main app logic.
requirejs(['kanaveral'], function() {
  console.log("Et voilà ! Tout est loaded !");
});
