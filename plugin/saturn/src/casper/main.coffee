
# Make casper and utils global variables
casper = require('casper').create(
  verbose: true,
  logLevel: "warning",
  clientScripts: ["build/casper_injected.js"],
  waitTimeout: 60000,
)
utils = require('utils')
Server = require('webserver').create()

requirejs ['casper_logger', "src/casper/session", 'src/casper/adblock', 'satconf'], (logger, CasperSession, AdBlock) ->
  # DEFINE CONSTANTS
  HOST = "127.0.0.1"
  PORT = casper.cli.get("port")
  NODE_PORT = casper.cli.get("node_port")
  logId =  "[Casper@#{PORT}]"

  # LOGS
  logger.level = logger.ALL#logger[satconf.log_level]
  casper.on 'console', (line) ->
    logger.info(logId + 'Fom console : ' + line)
  casper.on "page.error", (msg, trace) ->
    logger.error(logId, "Page: "+msg)
  casper.on "error", (msg, trace) ->
    logger.error(logId, msg)
    this.echo("Error:    " + msg, "ERROR");
    this.echo("file:     " + trace[0].file, "WARNING");
    this.echo("line:     " + trace[0].line, "WARNING");
    this.echo("function: " + trace[0]["function"], "WARNING");
  casper.on "step.error", (msg) ->
    logger.error(logId, "Step: "+msg)

  # ADBLOCK
  if casper.cli.get("adblock")
    startTime = Date.now()
    AdBlock.loadFromDisk()
    casper.on 'page.resource.requested', (requestData, request) ->
      request.abort() if AdBlock.isBlacklisted(requestData.url, casper.page.url)

  # CASPER_SATURN INIT

  # Retransmit signal emited in page with casper event system.
  casper.on 'page.created', (page) ->
    page.onCallback = (hash) ->
      return if typeof hash != 'object'
      casper.emit hash.signame, hash.data

  # Load and initialize Crawler when page is loaded.
  casper.on "load.finished", ->
    casper.evaluate (logId) ->
      # Create function to emit signal to casper.
      __utils__.sat_emit ?= (signame, data) ->
        window.callPhantom({signame: signame, data: data}) if typeof window.callPhantom == 'function'
      requirejs ['casper_logger', 'src/casper/crawler'], (logger, Crawler) ->
        return if window.crawler?
        logger.level = logger.ALL
        window.logId = logId
        window.crawler = new Crawler()
    , logId
    return true

  saturn = {
    logId: logId
    createServer: ->
      @initRequest = false
      @service = Server.listen "#{HOST}:#{PORT}", (request, response) =>
        logger.debug @logId, "Incoming request at '#{request.url}'."
        if request.url is "/subTaskFinished"
          try
            res = request.post
            @session.subTaskEnded(res)
            response.statusCode = 200
            response.closeGracefully()
          catch err
            logger.error @logId, err
            response.statusCode = 500
            response.write("Fail to parse post data")
            response.closeGracefully()
            return casper.exit()
        else if request.url is "/"
          try
            @initRequest = true # Casper stop to wait.
            prod = JSON.parse(request.post)
            this.createSession(prod)
            response.statusCode = 200
            response.closeGracefully()
          catch err
            logger.error @logId, "Fail to parse '#{request.post}'"
            response.statusCode = 500
            response.write("Fail to parse post data")
            response.closeGracefully()
            return casper.exit()
      logger.debug @logId, "Server launch. Listen on #{HOST}:#{PORT}"

      if casper.cli.get("prod")
        try
          prod = JSON.parse casper.cli.get("prod")
          this.createSession(prod)
          return
        catch err
          logger.error @logId, "Fail to parse '#{casper.cli.get("prod")}'"

      logger.debug @logId, "Send ready signal to NodeJS server on port #{NODE_PORT}"
      casper.evaluate( (host, nodePort, port) ->
        __utils__.sendAJAX("http://#{host}:#{nodePort}/casper-ready?session=#{port}", 'GET', null, true)
      , HOST, NODE_PORT, PORT)
      casper.then () =>
        logger.debug @logId, "Ajax request sent."
      casper.waitFor () =>
        @initRequest
      , null, () =>
        logger.error(@logId, "no product received !")
        casper.exit(1)
      , 5*60*1000 # 5 min

    createSession: (prod) ->
      logId = @logId = "[Casper@#{PORT}#{if prod.id then "#"+prod.id else ""}]"
      @session = new CasperSession(this, prod)
      # Signal emited when page has finished the eval.
      casper.on "saturn.evalDone", (result) =>
        @session.onEvalDone(result)
      # Signal emited when page/ajax is finished to load.
      casper.on "saturn.goNextStep", () =>
        @session.onGoNextStep()
      @session.start()

    addProductToQueue: (prod) ->
      prod._mainTaskPort = PORT
      casper.evaluate (url, prod) ->
        __utils__.sendAJAX(url, 'POST', JSON.stringify(prod), false, {"Content-Type": 'application/json'})
      , "http://localhost:#{NODE_PORT}/product", prod

    endSession: ->
      logger.trace(@logId, "CasperSaturn.endSession")
      casper.exit()
  }

  casper.start()
  casper.userAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/28.0.1500.71 Chrome/28.0.1500.71 Safari/537.36")
  casper.page.viewportSize = { width: 1920, height: 1200 }
  casper.then ->
    saturn.createServer()
  casper.run()
