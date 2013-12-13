define ['http', 'child_process', "logger", "../saturn_session"], (http, child_process, logger, SaturnSession) ->
  
  spawn = child_process.spawn

  class NodeSaturnSession extends SaturnSession
    constructor: (@serverPort, @sessionPort, args...) ->
      super(args...)

    start: ->
      logger.debug("[NodeJS] Launch casper on port : "+@sessionPort)
      casper = spawn('casperjs', ["--web-security=false", "src/casper/test.coffee", "--port="+@sessionPort, "--node_port="+@serverPort])

      casper.stdout.on 'data', (chunk) =>
        logger.debug("[CasperJS#"+@sessionPort+"] "+chunk.toString().trim())
      casper.stderr.on 'data', (chunk) =>
        logger.error("[CasperJS#"+@sessionPort+"] error="+chunk.toString().trim())
      casper.on 'close', (code) =>
        logger.debug("[CasperJS#"+@sessionPort+"] casper process #"+@prod_id+" exited with code " + code)

    onSessionReady: () ->
      prod = @products[port]
      prodJSON = JSON.stringify(prod)
      logger.debug("[NodeJS] On port "+@sessionPort+", going to start session.")

      request = http.request {
        host: "127.0.0.1",
        port: @sessionPort,
        method: 'POST',
        headers: {
          "Content-Type":"application/json",
          "Content-Length":Buffer.byteLength(prodJSON),
        },
      }, (response) =>
        logger.debug('STATUS: ' + response.statusCode)
        response.setEncoding('utf8')
        response.on 'data', (chunk) ->
          logger.debug("For url='"+prod.url+"', title='"+chunk+"'.")
      request.end(prodJSON)

    openNewTab: (prod) ->
      port = @portCounter++
      @products[port] = prod

      logger.debug("[NodeJS] Launch casper on port : "+port)
      casper = spawn('casperjs', ["--web-security=false", "src/casper/test.coffee", "--port="+port, "--node_port="+@serverPort])

      casper.stdout.on 'data', (chunk) ->
        logger.debug("[CasperJS#"+port+"] "+chunk.toString().trim())
      casper.stderr.on 'data', (chunk) ->
        logger.error("[CasperJS#"+port+"] error="+chunk.toString().trim())
      casper.on 'close', (code) ->
        logger.debug("[CasperJS#"+port+"] casper process #"+prod.id+" exited with code " + code)

  return NodeSaturn
