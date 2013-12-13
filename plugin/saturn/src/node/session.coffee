define ["logger", "src/saturn_session"], (logger, SaturnSession) ->
  
  http = require('http')
  spawn = require('child_process').spawn

  class NodeSaturnSession extends SaturnSession
    $$ = this;
    $$.instances = {}

    constructor: (saturn, @prod) ->
      @serverPort = saturn.serverPort
      @sessionPort = @prod.sessionPort
      delete @prod.sessionPort
      $$.instances[@sessionPort] = this

    start: ->
      logger.debug("[NodeJS] Launch casper on port : "+@sessionPort)
      casper = spawn('casperjs', ["--web-security=false", "dist/casper.js", "--port="+@sessionPort, "--node_port="+@serverPort])

      casper.stdout.on 'data', (chunk) =>
        logger.print(chunk.toString().trim())
      casper.stderr.on 'data', (chunk) =>
        logger.print(chunk.toString().trim())
      casper.on 'close', (code) =>
        logger.debug("[CasperJS#"+@sessionPort+"] casper process #"+@prod.url+" exited with code " + code)

    onMessage: (msg) ->
      if msg.casperReady
        this.onSessionReady()
      else
        logger.info("[NodeJS@"+@sessionPort+"] result is", msg.title)

    onSessionReady: () ->
      prodJSON = JSON.stringify(@prod)
      logger.debug("[NodeJS@"+@sessionPort+"] going to start session.")

      request = http.request {
        host: "127.0.0.1",
        port: @sessionPort,
        method: 'POST',
        headers: {
          "Content-Type":"application/json",
          "Content-Length":Buffer.byteLength(prodJSON),
        },
      }, (response) =>
        # response.setEncoding('utf8')
        # response.on 'data', (chunk) =>
        #   logger.debug("For url='"+@prod.url+"', title='"+chunk+"'.")
      request.end(prodJSON)

  return NodeSaturnSession
