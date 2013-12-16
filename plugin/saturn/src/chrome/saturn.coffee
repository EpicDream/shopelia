# ChromeSaturn
# Author : Vincent Renaudineau
# Created at : 2013-09-05
# ChromeSaturn
# Author : Vincent Renaudineau
# Created at : 2013-09-05

define ["jquery", "chrome_logger", "mapping", "src/saturn", 'src/chrome/session', 'satconf', 'core_extensions'],
($, logger, Mapping, Saturn, ChromeSaturnSession) ->
  class ChromeSaturn extends Saturn
    constructor: ->
      super
      @Session = ChromeSaturnSession
      @sessionsByTabId = ChromeSaturnSession.tabs
      @crawling = false

    start: ->
      this.resume()

    resume: ->
      return if @crawling
      @crawling = true
      this.main()

    pause: ->
      @crawling = false
      clearTimeout(@mainCallTimeout)

    stop: ->
      this.pause()
      for tabId, session in @sessionsByTabId
        session.fail("Saturn stopped.")

    main: ->
      return if ! @crawling
      # Send ajax request to get new product to crawl.
      $.ajax({
        type : "GET",
        dataType: "json",
        url: satconf.PRODUCT_EXTRACT_URL+(if satconf.consum then '' else "?consum=false")
      # Send ajax request to get new product to crawl.
      }).done( (array) =>
        if ! array || ! (array instanceof Array)
          logger.err("Error when getting new products to extract : received data is undefined or is not an Array")
          @mainCallTimeout = setTimeout( =>
            this.main()
          , satconf.DELAY_BETWEEN_PRODUCTS)
        else if array.length > 0
          logger.print("%c[%s] %d products received.", "color: blue", (new Date()).toLocaleTimeString(), array.length) unless logger.isInfo() || ! logger.isErr()
          this.onProductsReceived(array)
        else
          logger.print("%cNo product.", "color: blue") unless ! logger.isErr()
        @mainCallTimeout = setTimeout( =>
          this.main()
        , satconf.DELAY_BETWEEN_PRODUCTS)

      ).fail( (err) =>
        logger.error("Error when getting new products to extract :", err)
        @mainCallTimeout = setTimeout( =>
          this.main()
        , satconf.DELAY_BETWEEN_PRODUCTS)
      )

    # GET mapping for url's host,
    # and return jqXHR object.
    loadMapping: (merchantId, doneCallback, failCallback) ->
      logger.debug("Going to get mapping for merchantId '"+merchantId+"'")
      return Mapping.load(merchantId)

    parseCurrentPage: (tab) ->
      prod = {url: tab.url, tabId: tab.id, keepTabOpen: true}
      this.onProductReceived(prod)

    sendWarning: (prod, msg) ->
      if prod.extensionId
        saturn.externalPort.postMessage({url: prod.url, kind: prod.kind, tabId: prod.tabId, versions: [], warnMsg: msg})
      else if prod.prod_id # Stop pushed or Local Test
        $.ajax({
          type : "PUT",
          url: satconf.PRODUCT_EXTRACT_UPDATE+prod.prod_id,
          contentType: 'application/json',
          data: JSON.stringify({versions: [], warnMsg: msg})
        })
      super(prod, msg)

    sendError: (prod, msg) ->
      if prod.extensionId
        saturn.externalPort.postMessage({url: prod.url, kind: prod.kind, tabId: prod.tabId, versions: [], errorMsg: msg})
      else if prod.prod_id # Stop pushed or Local Test
        $.ajax({
          type : "PUT",
          url: satconf.PRODUCT_EXTRACT_UPDATE+prod.prod_id,
          contentType: 'application/json',
          data: JSON.stringify({versions: [], errorMsg: msg})
        }).fail (xhr, textStatus, errorThrown ) ->
          if textStatus is 'timeout' || xhr.status is 502
            $.ajax(this)
      super(prod, msg)

    closeTab: (tabId) ->
      session = @sessionsByTabId[tabId]
      if session
        session.sendError('Tab closed prematurely.')
        session.keepTabOpen = true; # To prevent that endSession() add the tab to pending.
        session.endSession()

  return ChromeSaturn
