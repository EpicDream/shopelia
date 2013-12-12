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
