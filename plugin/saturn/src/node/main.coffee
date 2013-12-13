
requirejs = require('requirejs');

requirejs.config({
  baseUrl: "./",
  nodeRequire: require,
  paths: {
    'src/chrome': 'build/src/chrome',
    'src/node': 'build/src/node',
    'src/casper': 'build/src/casper',

    core_extensions: "vendor/core_extensions",
    uri: "vendor/uri",
    logger: "vendor/logger",
    chrome_logger: "vendor/chrome_logger",
    casper_logger: "vendor/casper_logger",
    node_logger: "vendor/node_logger",
    sprintf: "vendor/sprintf",
    jquery: "vendor/jquery",
    underscore: "vendor/underscore",
    html_utils: "vendor/html_utils",
    crawler: "vendor/crawler",
    mapping: "vendor/mapping",
    satconf: "build/config"
  },
});

# require satconf and core_extensions in the global context. 
vm = require("vm")
fs = require("fs")
vm.runInThisContext(fs.readFileSync("./build/config.js"))
vm.runInThisContext(fs.readFileSync("./vendor/core_extensions.js"))

requirejs ['optimist', 'node_logger', 'src/node/saturn', 'satconf'], (optimist, logger, NodeSaturn) ->
  argv = optimist.argv
  serverPort = argv.port || 53746
  logger.level = logger.INFO;
  global.saturn = new NodeSaturn(serverPort)
  logger.info("[NodeJS] Server listen on port " + serverPort)
