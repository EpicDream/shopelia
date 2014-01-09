
define ['http', 'url', 'child_process', "logger", "mapping", "src/saturn"], (Http, Url, ChildProcess, logger, Mapping, Saturn) ->

  class NodeSaturn extends Saturn
    constructor: (@serverPort, args...) ->
      super(args...)
      @portCounter = @serverPort
      @server = Http.createServer( (req, res) =>
        uri = Url.parse(req.url, true)
        logger.debug("[NodeJS] Incoming connection from #{req.connection.remoteAddress}")

        if uri.pathname is "/casper-ready" && uri.query.session
          this.onSessionReady(uri.query.session)
          res.writeHead(204)
          return res.end()
        else if req.method is "POST" && req.url is '/product'
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
        else
          logger.error("[NodeJs] Unrecognise request : METHOD=#{req.method} and url=#{req.url}.")
          res.writeHead(400, {'Content-Type': 'text/plain'})
          return res.end("Unrecognise data.")
      ).listen(@serverPort)
    
    loadMapping: (merchantId, doneCallback, failCallback) ->
      Mapping.load(merchantId)

    createSession: (prod) ->
      port = prod.sessionPort = ++@portCounter
      @sessions[prod.sessionPort] = prod

      logger.debug("[NodeJS@#{port}] Going to launch casper for product #{if prod.id? then "##{prod.id}" else prod.url}")
      session = ChildProcess.spawn('casperjs', ["--web-security=false", "build/casper.js", "--port="+port, "--node_port="+@serverPort, "--adblock"])
      session.stdout.on 'data', (chunk) =>
        logger.print(chunk.toString().trim())
      session.stderr.on 'data', (chunk) =>
        logger.print(chunk.toString().trim())
      session.on 'close', (code) =>
        delete @sessions[port]
        logger.debug("[NodeJS#"+port+"] casper process exited with code " + code)

    onSessionReady: (port) ->
      prod = @sessions[port]
      prodJSON = JSON.stringify(prod)
      logger.debug("[NodeJS@"+port+"] going to start session.")
      Http.request(
        host: "127.0.0.1"
        port: port
        method: 'POST'
        headers:
          "Content-Type": "application/json"
          "Content-Length": Buffer.byteLength(prodJSON)
      ).end(prodJSON)

  return NodeSaturn
