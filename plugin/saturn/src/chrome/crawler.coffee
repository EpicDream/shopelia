# ChromeLogger
# Author : Vincent RENAUDINEAU
# Created : 2013-11-06

requirejs ['jquery', 'chrome_logger', 'crawler', 'src/helper', "satconf"],
($, logger, Crawler, Helper) ->

  logger.level = logger[satconf.log_level]
  window.Crawler = Crawler
  helper = Helper.get(location.href, 'crawler')

  chrome.extension.onMessage.addListener (hash, sender, callback) ->
    return if sender.id isnt chrome.runtime.id
    logger.debug("ProductCrawl", hash.action, "task received", hash)
    key = "option#{hash.option}"
    switch hash.action
      when "getOptions"
        result = if hash.mapping[key] then Crawler.getOptions(hash.mapping[key].paths) else []
      when "setOption"
        result = Crawler.setOption(hash.mapping[key].paths, hash.value)
      when "crawl"
        result = Crawler.crawl(hash.mapping)
      else
        logger.error("Unknow command", hash.action)
        result = false
    # wait minimal to let page reload on url change
    setTimeout(waitAjax, 1000) if hash.action is "setOption"
    callback(result) if callback?

  Crawler.onbeforeunloadBack = window.onbeforeunload
  window.onbeforeunload = () ->
    Crawler.pageWillBeUnloaded = true
    if typeof Crawler.onbeforeunloadBack is 'function'
      return Crawler.onbeforeunloadBack()

  goNextStep = () ->
    if ! Crawler.pageWillBeUnloaded
      chrome.extension.sendMessage("nextStep")

  waitAjax = () ->
    if helper && helper.waitAjax
      helper.waitAjax(goNextStep)
    else if ! Crawler.pageWillBeUnloaded
      setTimeout(goNextStep, satconf.DELAY_BETWEEN_OPTIONS)

  # To handle redirection, that throws false 'complete' state.
  $(document).ready () ->
    if helper && helper.atLoad
      helper.atLoad(goNextStep)
    else
      setTimeout(goNextStep, 100)
