# CasperSaturn
# Author : Vincent Renaudineau
# Created at : 2013-11-20

define(["casper_logger", "src/saturn", "src/casper/session", 'satconf'], (logger, Saturn, CasperSaturnSession) ->

  Server = require('webserver').create()

  class CasperSaturn extends Saturn
    constructor: (@host, @port, @nodePort) ->
      super()
      @Session = CasperSaturnSession
      @initRequest = false
      @caspId = "[Casper@#{@port}]"

      @service = Server.listen "#{@host}:#{@port}", (request, response) =>
        # Casper stop to wait.
        @initRequest = true

        logger.debug "#{@caspId} Incoming request."
        try
          prod = JSON.parse(request.post)
        catch err
          logger.error "#{@caspId} Fail to parse '#{request.post}'"
          return casper.exit()

        title = ""
        logger.debug "#{@caspId} Product received : going to open '#{prod.url}'"
        casper.thenOpen(prod.url).then () =>
          title = casper.getTitle()
          logger.info "#{@caspId} Title is #{title}"
          response.statusCode = 200
          response.write(title)
          response.close()

        casper.run () =>
          logger.debug "#{@caspId} Going to quit casper."
          return casper.exit()

      logger.debug "#{@caspId} Server launch. Listen on #{@host}:#{@port}"
      logger.debug "#{@caspId} Send ready signal to NodeJS server on port #{@nodePort}"

      casper.evaluate( (host, nodePort, port) ->
        __utils__.sendAJAX("http://#{host}:#{nodePort}/casper-ready?session=#{port}", 'GET', null, true)
      , @host, @nodePort, @port)
      casper.then () =>
        logger.debug "#{@caspId} Ajax request sent."
      casper.waitFor () =>
        @initRequest

  return CasperSaturn
)
