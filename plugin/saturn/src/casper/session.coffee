define ["casper_logger", "src/saturn_session"], (logger, SaturnSession) ->
  
  class CasperSaturnSession extends SaturnSession
    constructor: ->
      super

    # openUrl: (session, url) ->
    #   casper.open(url).waitFor =>
    #     @evalReturns is true
    #   , =>
    #     @evalReturns = false
    #   # .then ->
    #   #   session.start()
    #   #   if tab.url !== url
    #   #       # Priceminister fix when reload the same page with an #anchor set.
    #   #       if url.match(/#\w+(=\w+)?/)
    #   #         chrome.tabs.update(session.tabId, {url: url})
    #   #   # Priceminister fix when reload the same page with an #anchor set.
    #   #   else if url.match(/#\w+(=\w+)?/)
    #   #     chrome.tabs.update(session.tabId, {url: url})
    #   #   else
    #   #     session.next()

    # #
    # sendWarning: (session, msg) ->
    #   return if ! session.prod_id # Stop pushed or Local Test
    #   casper.evaluate( (prod_id, msg) ->
    #     $.ajax({
    #       type : "PUT",
    #       url: satconf.PRODUCT_EXTRACT_UPDATE+prod_id,
    #       contentType: 'application/json',
    #       data: JSON.stringify({versions: [], warnMsg: msg})
    #     })
    #   , session.prod_id, msg).then =>
    #     super session, msg

    # #
    # sendError: (session, msg) ->
    #   return if ! session.prod_id # Stop pushed or Local Test
    #   casper.evaluate( (prod_id, msg) ->
    #     $.ajax({
    #       type : "PUT",
    #       url: satconf.PRODUCT_EXTRACT_UPDATE+prod_id,
    #       contentType: 'application/json',
    #       data: JSON.stringify({versions: [], errorMsg: msg})
    #     }).fail (xhr, textStatus, errorThrown) ->
    #       $.ajax(this) if textStatus == 'timeout' || xhr.status == 502
    #   , session.prod_id, msg).then =>
    #     super session, msg

    # #
    # sendResult: (session, result) ->
    #   return if ! session.prod_id # Stop pushed or Local Test
    #   casper.evaluate( (prod_id, result) ->
    #     $.ajax({
    #       tryCount: 0,
    #       retryLimit: 1,
    #       type : "PUT",
    #       url: satconf.PRODUCT_EXTRACT_UPDATE+session.prod_id,
    #       contentType: 'application/json',
    #       data: JSON.stringify(result)
    #     }).fail((xhr, textStatus, errorThrown) ->
    #       if textStatus == 'timeout' || xhr.status == 502
    #         $.ajax(this)
    #       else if xhr.status == 500 && @tryCount < @retryLimit
    #         @tryCount++
    #         $.ajax(this)
    #       else
    #         logger.error(xhr.status, ":", textStatus)
    #     )
    #   , session.prod_id, result).then =>
    #     super session, result

    # onTimeout: (command) ->
    #   return =>
    #     # logger.debug("in evalAndThen, timeout for", command);
    #     command.callback = undefined
    #     this.sendError(command.session, "something went wrong", command)
    #     command.session.endSession()

    # #
    # evalAndThen: (session, cmd, callback) ->
    #   logger.debug("in evalAndThen with ", cmd.action, cmd.option, cmd.value) #cmd.mapping, 
    #   session.casper ?= {}
    #   session.casper.callback = callback
    #   casper.evaluate (session_id, action, mapping, option, value) ->
    #     requirejs ['casper_logger', 'src/casper/casper_crawler'], (logger, Crawler) ->
    #       Crawler.doNext(session_id, action, mapping, option, value)
    #   , session.id, cmd.action, cmd.mapping, cmd.option, cmd.value
    #   casper.waitFor =>
    #     @evalReturns is true
    #   , =>
    #     @evalReturns = false

    # onEvalDone: (data) ->
    #   @evalReturns = true
    #   casper.then(=>
    #     session = @sessions[data.session_id]
    #     session?.casper.callback?(data.result)
    #   )

    # onGoNextStep: (data) ->
    #   @evalReturns = true
    #   # casper.captureSelector("img_back/#{Date.now()}_amazon.jpg", "#handleBuy", {quality: 10})
    #   logger.debug "On 'saturn.goNextStep', session_id #{data.session_id} received !"
    #   casper.then(=>
    #     @sessions[data.session_id || 1]?.next()
    #   )


  return CasperSaturnSession
