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

define(['jquery', 'casper_logger', 'crawler', 'src/helper', 'satconf'], ($, logger, Crawler, Helper) ->

  helper = Helper.get(location.href, 'crawler')

  CasperCrawler = {
    goNextStep: () ->
      logger.debug("in Crawler.goNextStep")
      __utils__.sat_emit('saturn.goNextStep')

    waitAjax: () ->
      try
        # if location.host.search(/amazon.fr$/) != -1
        #   elem = $('#price_feature_div, #availability_feature_div, #ftMessage, #prime_feature_div').last()[0]
        #   if ! elem
        #     __utils__.echo("no elem found to test opacity !")
        #   if elem && elem.style.opacity != ''
        #     setTimeout(=>
        #       this.waitAjax()
        #     , 100)
        #   else
        #     this.goNextStep()
        if helper && helper.waitAjax
          helper.waitAjax(this.goNextStep)
        else
          setTimeout(this.goNextStep, satconf.DELAY_BETWEEN_OPTIONS)
      catch err
        logger.error("in waitAjax :", err.message)
        this.goNextStep()

    doNext: (action, mapping, option, value) ->
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
            this.waitAjax()
          , 1000)
        else
          __utils__.sat_emit 'saturn.evalDone', result
      catch err
        logger.error("in evalAndThen :", err.message)
        __utils__.sat_emit 'saturn.evalDone', false
  }

  CasperCrawler
)
