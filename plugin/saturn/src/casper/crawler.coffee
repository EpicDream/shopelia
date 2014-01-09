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
    goNextStep: () ->
      logger.debug("in Crawler.goNextStep")
      __utils__.sat_emit('saturn.goNextStep')

    doNext: (hash) ->
      try
        result = super
        __utils__.sat_emit('saturn.evalDone', result) if hash.action isnt "setOption"
      catch err
        logger.error("in evalAndThen :", err.message)
        __utils__.sat_emit 'saturn.evalDone', false

  CasperCrawler
)
