# ChromeSaturn
# Author : Vincent Renaudineau
# Created at : 2013-09-05

define ["jquery", "chrome_logger", "src/saturn", "mapping", 'satconf', 'core_extensions'], ($, logger, Saturn, Mapping) ->

  class ChromeSaturn extends Saturn
    constructor: () ->
      super()
      @results = {} # for debugging purpose, when there are no results sended by ajax.

    openNewTab: () ->
      @tabs.nbUpdating++
      logger.debug('in openNewTab')
      chrome.tabs.create {}, (tab) =>
        super(tab.id)

    cleanTab: (tabId) ->
      chrome.cookies.getAll {}, (cooks) =>
        for cookie in cooks
          chrome.cookies.remove {name: cookie.name, url: "http://"+cookie.domain+cookie.path, storeId: cookie.storeId}

    openUrl: (session, url) ->
      chrome.tabs.get session.tabId, (tab) ->
        if tab.url isnt url
          chrome.tabs.update session.tabId, {url: url}, (tab) ->
            # Priceminister fix when reload the same page with an #anchor set.
            if url.match(/#\w+(=\w+)?/)
              chrome.tabs.update(session.tabId, {url: url})
        # Priceminister fix when reload the same page with an #anchor set.
        else if url.match(/#\w+(=\w+)?/)
          chrome.tabs.update(session.tabId, {url: url})
        else
          session.next()

    closeTab: (tabId) ->
      logger.debug('in closeTab')
      super(tabId)
      chrome.tabs.remove(tabId)

    loadProductUrlsToExtract: (doneCallback, failCallback) ->
      # logger.debug("Going to get product_urls to extract...")
      return $.ajax({
        type : "GET",
        dataType: "json",
        url: satconf.PRODUCT_EXTRACT_URL+(if satconf.consum then '' else "?consum=false")
      }).done(doneCallback).fail(failCallback)

    # GET mapping for url's host,
    # and return jqXHR object.
    loadMapping: (merchantId, doneCallback, failCallback) ->
      logger.debug("Going to get mapping for merchantId '"+merchantId+"'")
      return Mapping.load(merchantId)

    # Get merchant_id from url.
    # Return an ajax object (see jqXHR on jQuery doc).
    getMerchantId: (url, callback) ->
      return $.ajax({
        type: "GET",
        dataType: "json",
        url: satconf.MAPPING_URL.slice(0,-1) + "?url=" + url
      })

    parseCurrentPage: (tab) ->
      prod = {url: tab.url, merchant_id: tab.url, tabId: tab.id, keepTabOpen: true}
      this.onProductReceived(prod)

    sendWarning: (session, msg) ->
      if session.extensionId
        saturn.externalPort.postMessage({url: session.url, kind: session.kind, tabId: session.tabId, versions: [], warnMsg: msg})
      else if session.prod_id # Stop pushed or Local Test
        $.ajax({
          type : "PUT",
          url: satconf.PRODUCT_EXTRACT_UPDATE+session.prod_id,
          contentType: 'application/json',
          data: JSON.stringify({versions: [], warnMsg: msg})
        })
      super(session, msg)

    sendError: (session, msg) ->
      if session.extensionId
        saturn.externalPort.postMessage({url: session.url, kind: session.kind, tabId: session.tabId, versions: [], errorMsg: msg})
      else if session.prod_id # Stop pushed or Local Test
        $.ajax({
          type : "PUT",
          url: satconf.PRODUCT_EXTRACT_UPDATE+session.prod_id,
          contentType: 'application/json',
          data: JSON.stringify({versions: [], errorMsg: msg})
        }).fail (xhr, textStatus, errorThrown ) ->
          if textStatus is 'timeout' || xhr.status is 502
            $.ajax(this)
      super(session, msg)

    sendResult: (session, result) ->
      logger.debug("sendResult : ", result)
      if session.extensionId
        result.url = session.url
        result.tabId = session.tabId
        result.kind = session.kind
        result.strategy = session.initialStrategy
        saturn.externalPort.postMessage(result)
      else if session.prod_id # Stop pushed or Local Test
        $.ajax({
          tryCount: 0,
          retryLimit: 1,
          type : "PUT",
          url: satconf.PRODUCT_EXTRACT_UPDATE+session.prod_id,
          contentType: 'application/json',
          data: JSON.stringify(result)
        }).fail (xhr, textStatus, errorThrown) ->
          if textStatus is 'timeout' || xhr.status is 502
            $.ajax(this)
          else if xhr.status is 500 && this.tryCount < this.retryLimit
            this.tryCount++
            $.ajax(this)
      else
        super(session, result)

    onTimeout: (session, cmd) ->
      this.sendError(session, "something went wrong", cmd)
      session.endSession()

    evalAndThen: (session, cmd, callback) ->
      if typeof callback is 'function'
        rescueTimer = window.setTimeout( () =>
          callback = undefined
          this.onTimeout(session, cmd)
        , satconf.DELAY_RESCUE)
        
      chrome.tabs.sendMessage session.tabId, cmd, (result) =>
        window.clearTimeout(rescueTimer)
        callback(result) if callback

  return ChromeSaturn
