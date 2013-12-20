define ["casper_logger", "src/saturn_session"], (logger, SaturnSession) ->
  
  class CasperSaturnSession extends SaturnSession

    constructor: ->
      super
      @casper = {}
      @evalReturns = false

    openUrl: () ->
      logger.debug("#{@saturn.caspId} Going to open #{@url}")
      casper.open(@url).waitFor () =>
        @evalReturns is true
      , () =>
        @evalReturns = false
        this.next()
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
      casper.evaluate( (url, data) ->
        requirejs ['jquery'], ($) ->
          $.ajax({type : "PUT", url: url, contentType: 'application/json', data: JSON.stringify(data)
          }).fail (xhr, textStatus, errorThrown) ->
            $.ajax(this) if textStatus == 'timeout' || xhr.status == 502
      , satconf.PRODUCT_EXTRACT_UPDATE+@prod_id, {versions: [], warnMsg: msg}).then () =>
        super msg

    #
    sendError: (msg) ->
      return if ! @prod_id # Stop pushed or Local Test
      casper.evaluate( (url, data) ->
        requirejs ['jquery'], ($) ->
          $.ajax({type : "PUT", url: url, contentType: 'application/json', data: JSON.stringify(data)
          }).fail (xhr, textStatus, errorThrown) ->
            $.ajax(this) if textStatus == 'timeout' || xhr.status == 502
      , satconf.PRODUCT_EXTRACT_UPDATE+@prod_id, {versions: [], errorMsg: msg}).then () =>
        super msg

    #
    sendResult: (result) ->
      return if ! @prod_id # Stop pushed or Local Test
      casper.evaluate( (url, data) ->
        requirejs ['jquery'], ($) ->
          $.ajax({type: "PUT", url: url, contentType: 'application/json', data: JSON.stringify(data), tryCount: 0, retryLimit: 1}
          ).fail (xhr, textStatus, errorThrown) ->
            if textStatus == 'timeout' || xhr.status == 502
              $.ajax(this)
            else if xhr.status == 500 && @tryCount < @retryLimit
              @tryCount++
              $.ajax(this)
            else
              logger.error(xhr.status, ":", textStatus)
      , satconf.PRODUCT_EXTRACT_UPDATE+@prod_id, result)
      casper.then () =>
        super result

    #
    evalAndThen: (cmd, callback) ->
      logger.debug("in evalAndThen with ", cmd.action, cmd.option, cmd.value) #cmd.mapping,
      @casper.callback = callback if callback?
      casper.evaluate (session_id, action, mapping, option, value) ->
        requirejs ['casper_logger', 'src/casper/crawler'], (logger, Crawler) ->
          Crawler.doNext(session_id, action, mapping, option, value)
      , @id, cmd.action, cmd.mapping, cmd.option, cmd.value
      casper.waitFor =>
        @evalReturns is true
      , =>
        @evalReturns = false

    onEvalDone: (result) ->
      @evalReturns = true
      casper.then () =>
        @evalReturns = false
        @casper.callback?(result)

    onGoNextStep: () ->
      @evalReturns = true
      casper.then () =>
        @evalReturns = false
        # @title = casper.getTitle()
        # logger.info "#{@saturn.caspId} Title is #{@title}"
        # this.endSession()
        this.next()

  return CasperSaturnSession
