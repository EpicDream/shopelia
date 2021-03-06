# CasperCrawler
# Author : Vincent Renaudineau
# Created at : 2013-11-26

# Fix
if window.CustomEvent == undefined
  window.CustomEvent = (event, params) ->
    params = params || { bubbles: false, cancelable: false, detail: undefined }
    evt = document.createEvent( 'CustomEvent' )
    evt.initCustomEvent( event, params.bubbles, params.cancelable, params.detail )
    evt
# Fix
if (! HTMLElement.prototype.click)
  HTMLElement.prototype.click = () ->
    this.dispatchEvent( new window.CustomEvent("click", {"canBubble":true, "cancelable":true}) )
# Fix
if (! XMLHttpRequest.prototype.overrideMimeType)
  XMLHttpRequest.prototype.overrideMimeType = ->

define(['jquery', 'casper_logger', 'crawler', 'satconf'], ($, logger, Crawler) ->

  Crawler.DELAY_BETWEEN_OPTIONS = satconf.DELAY_BETWEEN_OPTIONS

  class CasperCrawler extends Crawler
    constructor: ->
      super
      @resultSending = 0
      @logId = window.logId

    goNextStep: () ->
      # logger.debug("in Crawler.goNextStep")
      __utils__.sat_emit('saturn.goNextStep')

    doNext: (hash) ->
      try
        result = super
        __utils__.sat_emit('saturn.evalDone', result) if hash.action isnt "setOption"
      catch err
        logger.error(@logId, "in evalAndThen :", err.message)
        __utils__.sat_emit 'saturn.evalDone', false

    sendResult: (prod_id, result) ->
      @resultSending++
      crawler = this
      $.ajax(
        {type: "PUT", url: satconf.PRODUCT_EXTRACT_UPDATE+prod_id, contentType: 'application/json', data: JSON.stringify(result), tryCount: 0, retryLimit: 5}
      ).done( (res) =>
        @resultSending--
        logger.debug(@logId, "Result sended.")
      ).fail (xhr, textStatus, errorThrown) ->
        @tryCount++
        if @tryCount > @retryLimit
          crawler.resultSending--
          logger.error(window.logId, "Error #{xhr.status} (#{textStatus}) while sending result and max retry reached.")
        else if xhr.status == 502 # Server is restarting.
          setTimeout2 5000, () => $.ajax(this)
        else if xhr.status == 500 # DB race conflict
          setTimeout2 500, () => $.ajax(this)
        else
          setTimeout2 5000, () => $.ajax(this)
          logger.error(window.logId, "Error #{xhr.status} while sending result : #{textStatus}")

  CasperCrawler
)
