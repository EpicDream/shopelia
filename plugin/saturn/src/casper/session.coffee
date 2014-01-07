define ["casper_logger", "src/saturn_session"], (logger, Session) ->
  
  class CasperSession extends Session

    constructor: ->
      super
      @canSubTask = true
      @casper = {}
      @evalReturns = false

    openUrl: () ->
      logger.debug("#{@saturn.caspId} Going to open #{@url}")
      casper.open(@url).waitFor () =>
        @evalReturns is true
      , () =>
        @evalReturns = false
        this.next()
      , () =>
        this.fail("#{@saturn.caspId} Page takes too long to open.")

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

    logId: () ->
      "[Casper@#{@sessionPort}]"

    evalAndThen: (cmd, callback) ->
      @casper.callback = callback if callback?
      casper.evaluate (action, mapping, option, value) ->
        requirejs ['casper_logger', 'src/casper/crawler'], (logger, Crawler) ->
          Crawler.doNext(action, mapping, option, value)
      , cmd.action, cmd.mapping, cmd.option, cmd.value
      casper.waitFor =>
        @evalReturns is true
      , () =>
        @evalReturns = false
      , () =>
        this.fail("#{@saturn.caspId} Eval take too long to finish.")


    onEvalDone: (result) ->
      @evalReturns = true
      casper.then () =>
        @evalReturns = false
        @casper.callback?(result)

    onGoNextStep: () ->
      @evalReturns = true
      casper.then () =>
        @evalReturns = false
        this.next()

    preEndSession: () ->
      super
      casper.waitFor () =>
        @_subTasks is undefined
      , null
      , () =>
        this.fail("#{@saturn.caspId} Subtasks take too long to finish.")
      , satconf.DELAY_RESCUE * Object.keys(@_subTasks).length

  return CasperSession
