
# Make casper and utils global variables
casper = require('casper').create(
  verbose: true,
  logLevel: "warning",
  clientScripts: ["build/casper_injected.js"],
  waitTimeout: 30000,
)
utils = require('utils')
Server = require('webserver').create()

requirejs ['casper_logger', "src/casper/session", 'src/casper/adblock', 'satconf'], (logger, CasperSession, AdBlock) ->
  # DEFINE CONSTANTS
  HOST = "127.0.0.1"
  PORT = casper.cli.get("port")
  NODE_PORT = casper.cli.get("node_port")
  caspId =  "[Casper@#{PORT}]"

  # LOGS
  logger.level = logger.INFO#logger[satconf.log_level]
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
    casper.evaluate ->
      # Create function to emit signal to casper.
      __utils__.sat_emit ?= (signame, data) ->
        window.callPhantom({signame: signame, data: data}) if typeof window.callPhantom == 'function'
      requirejs ['casper_logger', 'src/casper/crawler'], (logger, Crawler) ->
        return if window.crawler?
        logger.level = logger.WARN
        window.crawler = new Crawler()
        window.crawler.goNextStep()
    return true

  saturn = {
    caspId: caspId
    createServer: ->
      @initRequest = false
      @service = Server.listen "#{HOST}:#{PORT}", (request, response) =>
        logger.debug "#{caspId} Incoming request at '#{request.url}'."
        if request.url is "/subTaskFinished"
          try
            res = request.post
            @session.subTaskEnded(res)
            response.statusCode = 200
            response.closeGracefully()
          catch err
            logger.error "#{caspId} #{err}."
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
            logger.error "#{caspId} Fail to parse '#{request.post}'"
            response.statusCode = 500
            response.write("Fail to parse post data")
            response.closeGracefully()
            return casper.exit()
      logger.debug "#{caspId} Server launch. Listen on #{HOST}:#{PORT}"
      logger.debug "#{caspId} Send ready signal to NodeJS server on port #{NODE_PORT}"

      casper.evaluate( (host, nodePort, port) ->
        __utils__.sendAJAX("http://#{host}:#{nodePort}/casper-ready?session=#{port}", 'GET', null, true)
      , HOST, NODE_PORT, PORT)
      casper.then () =>
        logger.debug "#{caspId} Ajax request sent."
      casper.waitFor () =>
        @initRequest
      , null, () =>
        logger.error("#{caspId} no product received !")
        casper.exit(1)
      , 5*60*1000 # 5 min


    createSession: (prod) ->
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
      casper.exit()
  }

  casper.start()
  casper.userAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/28.0.1500.71 Chrome/28.0.1500.71 Safari/537.36")
  casper.page.viewportSize = { width: 1920, height: 1200 }
  casper.then ->
    saturn.createServer()
  casper.run()
