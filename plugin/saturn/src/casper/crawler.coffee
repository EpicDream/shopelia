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
  logger.level = logger.ALL

  CasperCrawler = {
    goNextStep: (session_id) ->
      logger.debug("in Crawler.goNextStep")
      __utils__.sat_emit('saturn.goNextStep', {session_id: session_id || 1})

    waitAjax: (session_id) ->
      try
        # casper.capture("#{Date.now()}_amazon_#{data.session_id}.png")
        if location.host.search(/amazon.fr$/) != -1
          # __utils__.echo("in amazon")
          elem = $('#price_feature_div, #availability_feature_div, #ftMessage, #prime_feature_div').last()[0]
          if ! elem
            __utils__.echo("no elem found to test opacity !")
          if elem && elem.style.opacity != ''
            # __utils__.echo("opacity not empty", elem && elem.style.opacity)
            setTimeout(=>
              this.waitAjax(session_id)
            , 100)
          else
            # __utils__.echo("go next")
            this.goNextStep(session_id)
        else
          setTimeout(=>
            this.goNextStep(session_id)
          , satconf.DELAY_BETWEEN_OPTIONS)
      catch err
        logger.error("in waitAjax :", err.message)

    doNext: (session_id, action, mapping, option, value) ->
      try
        logger.info("Task received : '#{action}', '#{mapping}', '#{option}', '#{value && (value.text || value.value || value.id)}'")
        key = "option"+option
        switch action
          when "getOptions"
            if mapping[key]
              result = Crawler.getOptions(mapping[key].paths)
            else
              result = []
          when "setOption" then result = Crawler.setOption(mapping[key].paths, value)
          when "crawl" then result = Crawler.crawl(mapping)
          else
            logger.error("Unknow command", action)
            result = false
        logger.debug("Task result : '#{result}'")

        if action == "setOption"
          setTimeout(=>
            this.waitAjax(session_id)
          , 1000)
        else
          __utils__.sat_emit 'saturn.evalDone', {session_id: session_id, result: result}
      catch err
        logger.error("in evalAndThen :", err.message)
        __utils__.sat_emit 'saturn.evalDone', {session_id: session_id, result: false}
  }

  CasperCrawler
)
