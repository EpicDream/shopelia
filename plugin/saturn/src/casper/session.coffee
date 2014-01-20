define ["casper_logger", "src/saturn_session"], (logger, Session) ->
  
  class CasperSession extends Session

    constructor: ->
      super
      @canSubTask = true
      @casper = {}
      @evalReturns = false

    openUrl: () ->
      logger.debug(@logId(), "Going to open #{@url}")
      casper.open(@url).waitFor () =>
        @evalReturns is true
      , () =>
        @evalReturns = false
        this.next()
      , () =>
        this.fail("Page takes too long to open.")

    createSubTasks: () ->
      firstOption = @options.firstOption({nonAlone: true})
      return if ! firstOption # Possible if there is only a single choice
      option = firstOption.depth()+1
      hashes = Object.keys(firstOption._childrenH)
      @_subTasks = {}
      for hashCode in hashes[1..]
        prod = {
          id: @prod_id
          batch_mode: @batch_mode
          url: @url
          mapping: @mapping
          merchant_id: @merchant_id
          strategy: 'normal'
          argOptions: @options.argOptions
          _subTaskId: hashCode
          _mainTaskId: @id
        }
        prod.argOptions[option] = hashCode
        @_subTasks[hashCode] = prod
        firstOption.removeChild(firstOption.childAt(hashCode))
        @saturn.addProductToQueue(prod)
      @options.argOptions[option] = hashes[0]

    _onSubTaskFinished: ->
      casper.evaluate (url, data) ->
        __utils__.sendAJAX(url, "POST", data, false)
      , "http://localhost:#{@_mainTaskPort}/subTaskFinished", {_subTaskId: @_subTaskId, result: @results, _mainTaskId: @_mainTaskId}

    sendWarning: (msg) ->
      return if ! @prod_id # Stop pushed or Local Test
      casper.evaluate( (url, data) ->
        requirejs ['jquery'], ($) ->
          $.ajax({type : "PUT", url: url, contentType: 'application/json', data: JSON.stringify(data)
          }).fail (xhr, textStatus, errorThrown) ->
            $.ajax(this) if textStatus == 'timeout' || xhr.status == 502
      , satconf.PRODUCT_EXTRACT_UPDATE+@prod_id, {versions: [], warnMsg: msg})
      casper.then () =>
        super msg

    sendError: (msg) ->
      return if ! @prod_id # Stop pushed or Local Test
      casper.evaluate( (url, data) ->
        requirejs ['jquery'], ($) ->
          $.ajax({type : "PUT", url: url, contentType: 'application/json', data: JSON.stringify(data)
          }).fail (xhr, textStatus, errorThrown) ->
            $.ajax(this) if textStatus == 'timeout' || xhr.status == 502
      , satconf.PRODUCT_EXTRACT_UPDATE+@prod_id, {versions: [], errorMsg: msg})
      casper.then () =>
        super msg

    sendResult: (result) ->
      logger.trace(@logId(), "CasperSession.sendResult")
      return if ! @prod_id # Stop pushed or Local Test
      casper.evaluate( (prod_id, result) ->
        window.crawler.sendResult(prod_id, result)
      , @prod_id, result)
      casper.then () =>
        super result

    logId: () ->
      @saturn.logId

    evalAndThen: (cmd, callback) ->
      logger.trace(@logId(), "CasperSession.evalAndThen", cmd.action)
      @casper.callback = callback if callback?
      casper.evaluate (hash) ->
        requirejs ["casper_logger", "crawler"], (logger, Crawler) ->
          window.crawler.doNext(hash)
      , cmd
      casper.waitFor () ->
        false # Unwait it in onEvalDone

    onEvalDone: (result) ->
      logger.trace(@logId(), "CasperSession.onEvalDone")
      # @evalReturns = true
      casper.unwait()
      @casper.callback?(result)

    onGoNextStep: () ->
      logger.trace(@logId(), "CasperSession.onGoNextStep")
      # @evalReturns = true
      return if @strategy is "ended"
      casper.unwait()
      this.next()

    preEndSession: () ->
      logger.trace(@logId(), "CasperSession.preEndSession")
      super
      if @_subTasks
        casper.waitFor () =>
          @_subTasks is undefined
        , null
        , () =>
          this.fail("Subtasks take too long to finish.")
        , satconf.DELAY_RESCUE * Object.keys(@_subTasks).length

    endSession: ->
      logger.trace(@logId(), "CasperSession.endSession")
      setTimeout2 1000, () =>
        nb = casper.evaluate () ->
          window.crawler.resultSending
        if nb is 0
          logger.debug(@logId(), "Evaluate to 0, Before Session.endSession")
          super
        else
          logger.error(@logId(), "Try to endSession with still #{nb} result being send.")
          this.endSession()

    onTimeout: () ->
      logger.trace(@logId(), "CasperSession.onTimeout")
      casper.unwait()
      # try to reload before to fail.
      if ! @alreadyRetried && @strategy isnt 'ended'
        @alreadyRetried = true
        @rescueTimeout = setTimeout2 satconf.DELAY_RESCUE, => this.onTimeout()
        casper.reload () => this.retryLastCmd()
      else
        super

  return CasperSession
