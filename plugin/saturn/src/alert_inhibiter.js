// ChromeLogger
// Author : Vincent RENAUDINEAU
// Created : 2013-12-11

(function () {
  if (typeof jasmine !== 'undefined')
    return;
  // Disable window.alert function.
  var script = document.createElement("script");
  script.type = "text/javascript";
  script.innerHTML = "(function () {window.alert = function() {};})();";
  (document.head || document.documentElement).appendChild(script);
})();
