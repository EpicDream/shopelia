define ["casper_logger", "src/saturn_session"], (logger, SaturnSession) ->
  
  class CasperSaturnSession extends SaturnSession

    openUrl: () ->
      logger.debug("#{@saturn.caspId} Going to open #{@url}")
      casper.open(@url).then () =>
        title = casper.getTitle()
        logger.info "#{@saturn.caspId} Title is #{title}"
        this.endSession()

      # casper.open(@url).waitFor () =>
      #   @evalReturns is true
      # , () =>
      #   @evalReturns = false
      #   this.next()
      # .then () =>
      #   if tab.url !== @url
      #       # Priceminister fix when reload the same page with an #anchor set.
      #       if @url.match(/#\w+(=\w+)?/)
      #         chrome.tabs.update(session.tabId, {url: url})
      #   # Priceminister fix when reload the same page with an #anchor set.
      #   else if url.match(/#\w+(=\w+)?/)
      #     chrome.tabs.update(session.tabId, {url: url})
      #   else
      #     session.next()

    #
    sendWarning: (msg) ->
      return if ! @prod_id # Stop pushed or Local Test
      casper.evaluate( (data) ->
        $.ajax({type : "PUT", url: url, contentType: 'application/json', data: JSON.stringify(data)
        }).fail (xhr, textStatus, errorThrown) ->
          $.ajax(this) if textStatus == 'timeout' || xhr.status == 502
      , satconf.PRODUCT_EXTRACT_UPDATE+prod_id, {versions: [], warnMsg: msg}).then =>
        super msg

    #
    sendError: (msg) ->
      return if ! @prod_id # Stop pushed or Local Test
      casper.evaluate( (data) ->
        $.ajax({type : "PUT", url: url, contentType: 'application/json', data: JSON.stringify(data)
        }).fail (xhr, textStatus, errorThrown) ->
          $.ajax(this) if textStatus == 'timeout' || xhr.status == 502
      , satconf.PRODUCT_EXTRACT_UPDATE+prod_id, {versions: [], errorMsg: msg}).then =>
        super msg

    #
    sendResult: (result) ->
      return if ! @prod_id # Stop pushed or Local Test
      casper.evaluate( (url, data) ->
        $.ajax({type: "PUT", url: url, contentType: 'application/json', data: JSON.stringify(data), tryCount: 0, retryLimit: 1}
        ).fail (xhr, textStatus, errorThrown) ->
          if textStatus == 'timeout' || xhr.status == 502
            $.ajax(this)
          else if xhr.status == 500 && @tryCount < @retryLimit
            @tryCount++
            $.ajax(this)
          else
            logger.error(xhr.status, ":", textStatus)
      , satconf.PRODUCT_EXTRACT_UPDATE+prod_id, result).then =>
        super result

    # onTimeout: (command) ->
    #   return =>
    #     # logger.debug("in evalAndThen, timeout for", command);
    #     command.callback = undefined
    #     this.sendError(command.session, "something went wrong", command)
    #     command.session.endSession()

    #
    evalAndThen: (cmd, callback) ->
      logger.debug("in evalAndThen with ", cmd.action, cmd.option, cmd.value) #cmd.mapping,
      @casper ?= {}
      @casper.callback = callback
      callback(if cmd.action is 'getOptions' then [] else {}) if callback?
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
