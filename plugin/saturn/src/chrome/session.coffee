# ChromeSaturn
# Author : Vincent Renaudineau
# Created at : 2013-09-05

define ["jquery", "chrome_logger", "../saturn_session", "mapping", 'satconf', 'core_extensions'], ($, logger, SaturnSession, Mapping) ->

  class ChromeSaturnSession extends SaturnSession
    # Class variables
    $$ = this
    $$.tabs = {}
    $$.tabsBeenOpened = 0
    $$.pendings = []

    # Class methods
    $$.canOpenNewTab = () ->
      (Object.keys($$.tabs).length+$$.tabsBeenOpened) < satconf.MAX_NB_TABS

    $$.addToPending = (session) ->
      $$.pendings.push(session)

    $$.startNext = () ->
      $$.pendings.shift().start() if $$.pendings.length > 0

    ####################################################

    constructor: ->
      super
      @canSubTask = true
      @alreadyRetried = false

    start: () ->
      if @tabId?
        $$.tabs[@tabId] = this
        @rescueTimeout = setTimeout( =>
          this.onTimeout()
        , satconf.DELAY_RESCUE)
        this.openUrl()
      else if $$.canOpenNewTab()
        @rescueTimeout = setTimeout(=>
          this.onTimeout()
        , satconf.DELAY_RESCUE)
        this.openNewTab() 
      else
        $$.addToPending(this)

    evalAndThen: (cmd, callback) ->
      chrome.tabs.sendMessage(@tabId, cmd, callback)

    preEndSession: () ->
      super
      this.closeTab()

    endSession: () ->
      this.closeTab()
      super
      $$.startNext()

    sendWarning: (msg) ->
      if @extensionId
        @saturn.externalPort.postMessage {url: @url, kind: @kind, tabId: @tabId, versions: [], warnMsg: msg}
      else if @prod_id # Stop pushed or Local Test
        $.ajax {
          type : "PUT",
          url: satconf.PRODUCT_EXTRACT_UPDATE+@prod_id,
          contentType: 'application/json',
          data: JSON.stringify {versions: [], warnMsg: msg}
        }
      super msg

    sendError: (msg) ->
      if @extensionId
        saturn.externalPort.postMessage {url: @url, kind: @kind, tabId: @tabId, versions: [], errorMsg: msg}
      else if @prod_id # Stop pushed or Local Test
        $.ajax({
          type : "PUT",
          url: satconf.PRODUCT_EXTRACT_UPDATE+@prod_id,
          contentType: 'application/json',
          data: JSON.stringify({versions: [], errorMsg: msg})
        }).fail (xhr, textStatus, errorThrown ) ->
          if textStatus is 'timeout' || xhr.status is 502
            $.ajax(this)
      super msg

    sendResult: (result) ->
      if @extensionId
        result.url = @url
        result.tabId = @tabId
        result.kind = @kind
        result.strategy = @initialStrategy
        saturn.externalPort.postMessage result
      else if @prod_id # Stop pushed or Local Test
        $.ajax({
          tryCount: 0,
          retryLimit: 1,
          type : "PUT",
          url: satconf.PRODUCT_EXTRACT_UPDATE+@prod_id,
          contentType: 'application/json',
          data: JSON.stringify result
        }).fail (xhr, textStatus, errorThrown) ->
          if textStatus is 'timeout' || xhr.status is 502
            $.ajax(this)
          else if xhr.status is 500 && this.tryCount < this.retryLimit
            this.tryCount++
            $.ajax(this)
      super result

    logId: () ->
      super + if @tabId? then "@#{@tabId}" else ''

    ####################################################

    openNewTab: () ->
      $$.tabsBeenOpened++
      chrome.tabs.create {active: false}, (tab) =>
        @tabId = tab.id
        $$.tabs[@tabId] = this
        $$.tabsBeenOpened--
        this.cleanTab()

    cleanTab: () ->
      chrome.cookies.getAll {}, (cooks) =>
        for cookie in cooks
          chrome.cookies.remove({name: cookie.name, url: "http://"+cookie.domain+cookie.path, storeId: cookie.storeId})
      this.openUrl()

    openUrl: () ->
      chrome.tabs.get @tabId, (tab) =>
        if tab.url != @url
          chrome.tabs.update @tabId, {url: @url}, (tab) =>
            # Priceminister fix when reload the same page with an #anchor set.
            if @url.match(/#\w+(=\w+)?/)
              chrome.tabs.update(@tabId, {url: @url})
        # Priceminister fix when reload the same page with an #anchor set.
        else if @url.match(/#\w+(=\w+)?/)
          chrome.tabs.update(@tabId, {url: @url})
        else
          this.next()

    closeTab: () ->
      @alreadyRetried = true
      delete $$.tabs[@tabId]
      return if @keepTabOpen || ! @tabId
      chrome.tabs.remove(@tabId)
      @oldTabId = @tabId;
      @tabId = undefined

    onTimeout: () ->
      # try to reload before to fail.
      if ! @alreadyRetried && @strategy isnt 'ended'
        @rescueTimeout = setTimeout(=>
          this.onTimeout()
        , satconf.DELAY_RESCUE)
        chrome.tabs.reload @tabId, =>
          this.retryLastCmd()
        @alreadyRetried = true
      else
        super

  return ChromeSaturnSession
