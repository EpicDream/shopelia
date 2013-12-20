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
        try
          # Casper stop to wait.
          @initRequest = true
          logger.debug "#{@caspId} Incoming request."
          prod = JSON.parse(request.post)
          this.onProductReceived(prod)
          # response.statusCode = 200
          # response.close()
        catch err
          logger.error "#{@caspId} Fail to parse '#{request.post}'"
          response.statusCode = 500
          response.write("Fail to parse post data")
          response.close()
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

    onEvalDone: (data) ->
      @sessions[data.session_id]?.onEvalDone(data.result)

    onGoNextStep: (data) ->
      # casper.captureSelector("img_back/#{Date.now()}_amazon.jpg", "#handleBuy", {quality: 10})
      logger.debug "On 'saturn.goNextStep', session_id #{data.session_id} received !"
      @sessions[data.session_id || 1]?.onGoNextStep()

    endSession: (session) ->
      super
      return casper.exit()

    sendWarning: (prod, msg) ->
      return if ! prod.prod_id
      casper.evaluate (data) ->
        requirejs ['jquery'], ($) ->
          $.ajax({
            type : "PUT",
            url: satconf.PRODUCT_EXTRACT_UPDATE+prod.prod_id,
            contentType: 'application/json',
            data: JSON.stringify(data)
          }).fail (xhr, textStatus, errorThrown ) ->
            if textStatus is 'timeout' || xhr.status is 502
              $.ajax(this)
      , {versions: [], warnMsg: msg}
      super(prod, msg)

    sendError: (prod, msg) ->
      return if ! prod.prod_id
      casper.evaluate (url, data) ->
        requirejs ['jquery'], ($) ->
          $.ajax({
            type : "PUT",
            url: url,
            contentType: 'application/json',
            data: JSON.stringify(data)
          }).fail (xhr, textStatus, errorThrown ) ->
            if textStatus is 'timeout' || xhr.status is 502
              $.ajax(this)
      , satconf.PRODUCT_EXTRACT_UPDATE+prod.prod_id, {versions: [], errorMsg: msg}
      super(prod, msg)

  return CasperSaturn
)
