require.config({
  paths: {
    uri: "vendor/uri",
    logger: "vendor/logger",
    sprintf: "vendor/sprintf",
    "jquery-ui": "vendor/jquery-ui",
    jquery: "vendor/jquery",
    "jquery-mobile": "vendor/jquery-mobile",
    underscore: "vendor/underscore",
    viking: "vendor/viking",
    html_utils: "vendor/html_utils",
    arconf: "build/config"
  },
  shim: {
    'jquery-ui': {
      deps: ['jquery'],
      init: function($){return $;}
    },
  }
});
