
define ['http', 'https', 'url', 'child_process', "logger", "mapping", "src/saturn"], (Http, Https, Url, ChildProcess, logger, Mapping, Saturn) ->

  class NodeSaturn extends Saturn
    constructor: (@serverPort, args...) ->
      super(args...)
      @portCounter = @serverPort
      @acceptProduct = true
      @server = Http.createServer( (req, res) =>
        uri = Url.parse(req.url, true)
        logger.debug("[NodeJS] Incoming connection from #{req.connection.remoteAddress}")

        if uri.pathname is "/casper-ready" && uri.query.session
          this.onSessionReady(uri.query.session)
          res.writeHead(204)
          return res.end()
        else if req.method is "POST" && req.url is '/product' && @acceptProduct
          req.setEncoding('utf8')
          return req.on 'data', (chunk) =>
            logger.debug("[NodeJS] Data received : " + chunk);
            try
              prod = JSON.parse(chunk)
              logger.verbose("[NodeJS] New product received : #{prod.url}") unless prod._mainTaskId
              this.onProductReceived(prod)
              res.writeHead(204)
              res.end()
            catch err
              logger.error("[NodeJs] fail to parse chunk :" + chunk)
              res.writeHead(500, {'Content-Type': 'text/plain'})
              res.end("Fail to parse request")
        else if req.method is "POST" && req.url is '/exit'
          this.quit()
        else if req.method is "POST" && req.url is '/product' && ! @acceptProduct
          res.writeHead(503)
          return res.end()
        else
          logger.error("[NodeJs] Unrecognise request : METHOD=#{req.method} and url=#{req.url}.")
          res.writeHead(400, {'Content-Type': 'text/plain'})
          return res.end("Unrecognise data.")
      ).listen(@serverPort)
    
    preProcessData: (data) ->
      prod = super
      prod._mainTaskId = data._mainTaskId
      prod._mainTaskPort = data._mainTaskPort
      prod

    loadMapping: (merchantId, doneCallback, failCallback) ->
      Mapping.load(merchantId)

    canStartANewSession: () ->
      Object.keys(@sessions).length <= satconf.MAX_SIMULTANEOUS_SESSION

    crawlProduct: () ->
      super if this.canStartANewSession()

    createSession: (prod) ->
      port = prod.sessionPort = ++@portCounter
      logId = "[NodeJS@#{port}#{if prod.id then "#"+prod.id else ""}]"

      logger.debug(logId, "Going to launch casper for product #{prod.url}")
      session = ChildProcess.spawn('casperjs', ["--web-security=false", "build/casper.js", "--port="+port, "--node_port="+@serverPort, "--prod="+JSON.stringify(prod), "--adblock"])
      prod.logId = logId # Si on le fait avant, le JSON.parse de CasperSession plante !??
      @sessions[prod.sessionPort] = {process: session, prod: prod}

      session.stdout.on 'data', (chunk) =>
        this.logCasper(chunk.toString().trim())
      session.stderr.on 'data', (chunk) =>
        this.logCasper(chunk.toString().trim())
      session.on 'close', (code) =>
        logger.debug(logId, "casper process exited with code " + code)
        this.clearSession(port)

    onSessionReady: (port) ->
      prod = @sessions[port].prod
      prodJSON = JSON.stringify(prod)
      logger.debug(prod.logId, "going to start session.")
      Http.request(
        host: "127.0.0.1"
        port: port
        method: 'POST'
        headers:
          "Content-Type": "application/json"
          "Content-Length": Buffer.byteLength(prodJSON)
      ).end(prodJSON)
      @sessions[port].started = true

    clearSession: (port) ->
      delete @sessions[port]
      this.crawlProduct()

    startPolling: () ->
      options = require('url').parse( 'https://www.shopelia.com/api/viking/products' );
      options.rejectUnauthorized = false;
      options.agent = new Https.Agent( options );
      @timerId = setInterval2 1000, () =>
        return unless this.canStartANewSession()
        Https.get(options, (res) =>
          return logger.error("[NodeJS] Error #{res.statusCode} retrieving products to crawl : #{Http.STATUS_CODES[res.statusCode]}") if res.statusCode isnt 200
          data = ""
          res.on "data", (chunk) =>
            data += chunk
            try
              prods = JSON.parse data
              data = ""
            catch err
              return
            return unless prods.length > 0
            logger.verbose("[NodeJS] New products received : #{prods.length}")
            this.onProductsReceived(prods)
        ).on 'error', (err) ->
          logger.error("[NodeJS] Get product connection error : #{err}")

    stopPolling: () ->
      clearInterval(@timerId)
      @timerId = undefined

    sendError: (prod, msg) ->
      if prod.prod_id # Stop pushed or Local Test
        Http.request({
          method : "PUT",
          url: satconf.PRODUCT_EXTRACT_UPDATE+prod.prod_id,
          contentType: 'application/json',
          data: JSON.stringify({versions: [], errorMsg: msg})
        }, (res) =>
          if res.statusCode is 408 || res.statusCode is 502 # Timeout or Unreachable
            setTimeout2 5000, () => this.sendError(prod, msg)
        )

      super(prod, msg)

    sendWarning: (prod, msg) ->
      if prod.prod_id # Stop pushed or Local Test
        Http.request({
          method : "PUT",
          url: satconf.PRODUCT_EXTRACT_UPDATE+prod.prod_id,
          contentType: 'application/json',
          data: JSON.stringify({versions: [], warnMsg: msg})
        }, (res) =>
          if res.statusCode is 408 || res.statusCode is 502 # Timeout or Unreachable
            setTimeout2 5000, () => this.sendWarning(prod, msg)
        )

    quit: () ->
      @acceptProduct = false
      this.stopPolling()

    logCasper: (chunk) ->
      level = chunk.match(/\[[A-Z ]{5}\]/)?[0] || "[PRINT]"
      logger.write(level.slice(1,-1).trim(), chunk)

  return NodeSaturn
