
define ["logger", "mapping", "src/saturn", "src/node/session"], (logger, Mapping, Saturn, NodeSaturnSession) ->
  
  http = require('http')
  parseUrl = require('url').parse

  class NodeSaturn extends Saturn
    constructor: (@serverPort, args...) ->
      super(args...)
      @Session = NodeSaturnSession
      @sessionsByPort = NodeSaturnSession.instances
      @portCounter = @serverPort

      @server = http.createServer( (req, res) =>
        uri = parseUrl(req.url, true)
        logger.info("[NodeJS] Incoming connection from #{req.headers.host}#{uri.href}")

        if uri.pathname is "/casper-ready" && uri.query.session
          @sessionsByPort[uri.query.session].onSessionReady()
          res.writeHead(204)
          return res.end()
        else if req.method is "POST" && req.url is '/'
          req.setEncoding('utf8')
          return req.on 'data', (chunk) =>
            logger.debug("[NodeJS] Data received : " + chunk);
            try
              prod = JSON.parse(chunk)
              logger.info("[NodeJS] New product received : #{prod.url}")
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

    preProcessData: (prod) ->
      prod = super(prod)
      prod.sessionPort = ++@portCounter
      return prod
    
    loadMapping: (merchantId, doneCallback, failCallback) ->
      logger.debug("Going to get mapping for merchantId '"+merchantId+"'")
      return Mapping.load(merchantId)

  return NodeSaturn



define ["logger", "mapping", "src/saturn", "src/node/session"], (logger, Mapping, Saturn, NodeSaturnSession) ->
  
  http = require('http')
  parseUrl = require('url').parse

  class NodeSaturn extends Saturn
    constructor: (@serverPort, args...) ->
      super(args...)
      @Session = NodeSaturnSession
      @sessionsByPort = NodeSaturnSession.instances
      @portCounter = @serverPort

      @server = http.createServer( (req, res) =>
        uri = parseUrl(req.url)
        logger.info("[NodeJS] Incoming connection from #{req.headers.host}#{uri.pathname}?#{typeof req.query}")
        req.setEncoding('utf8')
        return req.on 'data', (chunk) =>
          logger.debug("[NodeJS] Data received : " + chunk);
          try
            data = JSON.parse(chunk)
          catch err
            logger.error("[NodeJs] fail to parse chunk :" + chunk)
            res.writeHead(500, {'Content-Type': 'text/plain'})
            res.end("Fail to parse request")
            return

          if uri.pathname is "/casper-ready"
            @sessionsByPort[data.sessionPort].onSessionReady()
            res.writeHead(204)
            return res.end()
          else if req.url is "/"
            logger.info("[NodeJS] New product received.");
            prod = data
            this.onProductReceived(prod)
            res.writeHead(204)
            return res.end()
          else
            logger.error("[NodeJs] Unrecognise data.")
            res.writeHead(400, {'Content-Type': 'text/plain'})
            return res.end("Unrecognise data.")
      ).listen(@serverPort)

    preProcessData: (prod) ->
      prod = super(prod)
      prod.sessionPort = ++@portCounter
      return prod
    
    loadMapping: (merchantId, doneCallback, failCallback) ->
      logger.debug("Going to get mapping for merchantId '"+merchantId+"'")
      return Mapping.load(merchantId)

  return NodeSaturn
