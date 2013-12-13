
# Make casper and utils global variables
casper = require('casper').create(
  verbose: true,
  logLevel: "warning",
  clientScripts: ["build/casper_injected.js"],
  waitTimeout: 30000,
)
utils = require('utils')

requirejs ['casper_logger', 'src/casper/saturn', 'satconf'], (logger, CasperSaturn) ->
  # DEFINE CONSTANTS
  HOST = "127.0.0.1"
  PORT = casper.cli.get("port")
  NODE_PORT = casper.cli.get("node_port")
  caspId =  "[Casper@#{PORT}]"

  # LOGS
  logger.level = logger.ALL#logger[satconf.log_level]
  casper.on 'console', (line) ->
    logger.info(caspId + 'Fom console : ' + line)
  casper.on "page.error", (msg, trace) ->
    logger.error(caspId, "Page: "+msg)
  casper.on "error", (msg, trace) ->
    logger.error(caspId, msg)
    this.echo("Error:    " + msg, "ERROR");
    this.echo("file:     " + trace[0].file, "WARNING");
    this.echo("line:     " + trace[0].line, "WARNING");
    this.echo("function: " + trace[0]["function"], "WARNING");
  casper.on "step.error", (msg) ->
    logger.error(caspId, "Step: "+msg)

  # CASPER_SATURN INIT
  casper.start()
  casper.userAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/28.0.1500.71 Chrome/28.0.1500.71 Safari/537.36")
  casper.page.viewportSize = { width: 1920, height: 1200 }
  casper.then ->
    saturn = new CasperSaturn(HOST, PORT, NODE_PORT)
  casper.run()
