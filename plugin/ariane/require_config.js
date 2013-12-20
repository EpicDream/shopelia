requirejs.config({
  paths: {
    core_extensions: "vendor/core_extensions",
    uri: "vendor/uri",
    logger: "vendor/logger",
    chrome_logger: "vendor/chrome_logger",
    sprintf: "vendor/sprintf",
    sorted_array: "vendor/sorted_array",
    "jquery-ui": "vendor/jquery-ui",
    jquery: "vendor/jquery",
    "jquery-mobile": "vendor/jquery-mobile",
    underscore: "vendor/underscore",
    viking: "vendor/viking",
    html_utils: "vendor/html_utils",
    crawler: "vendor/crawler",
    mapping: "vendor/mapping",
    arconf: "build/config"
  },
  shim: {
    'jquery-ui': {
      deps: ['jquery'],
      init: function($){return $;}
    },
  }
});
