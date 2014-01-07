# ChromeLogger
# Author : Vincent RENAUDINEAU
# Created : 2013-11-06

requirejs ['jquery', 'chrome_logger', 'crawler', "satconf"],
($, logger, Crawler) ->

  logger.level = logger[satconf.log_level]
  crawler = new Crawler()
  window.crawler = crawler
  helper = crawler.helper

  chrome.extension.onMessage.addListener (hash, sender, callback) ->
    return if sender.id isnt chrome.runtime.id
    logger.debug("ProductCrawl", hash.action, "task received", hash)
    key = "option#{hash.option}"
    switch hash.action
      when "getOptions"
        result = if hash.mapping[key] then crawler.getOptions(hash.mapping[key].paths) else []
      when "setOption"
        result = crawler.setOption(hash.mapping[key].paths, hash.value)
      when "crawl"
        result = crawler.crawl(hash.mapping)
      else
        logger.error("Unknow command", hash.action)
        result = false
    # wait minimal to let page reload on url change
    setTimeout(waitAjax, 1000) if hash.action is "setOption"
    callback(result) if callback?

  crawler.onbeforeunloadBack = window.onbeforeunload
  window.onbeforeunload = () ->
    crawler.pageWillBeUnloaded = true
    if typeof crawler.onbeforeunloadBack is 'function'
      return crawler.onbeforeunloadBack()

  goNextStep = () ->
    if ! crawler.pageWillBeUnloaded
      chrome.extension.sendMessage("nextStep")

  waitAjax = () ->
    if helper && helper.waitAjax
      helper.waitAjax(goNextStep)
    else if ! crawler.pageWillBeUnloaded
      setTimeout(goNextStep, satconf.DELAY_BETWEEN_OPTIONS)

  # To handle redirection, that throws false 'complete' state.
  $(document).ready () ->
    if helper && helper.atLoad
      helper.atLoad(goNextStep)
    else
      setTimeout(goNextStep, 100)
