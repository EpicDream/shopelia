# ChromeLogger
# Author : Vincent RENAUDINEAU
# Created : 2013-11-06

require ['chrome_logger', 'crawler', 'src/helper', "satconf"], (logger, Crawler, helper) ->

  window.Crawler = Crawler
  logger.level = logger[satconf.log_level]
  crawlHelper = helper.get(location.href)?.crawler

  chrome.extension.onMessage.addListener (hash, sender, callback) ->
    return if sender.id isnt chrome.runtime.id
    logger.debug("ProductCrawl", hash.action, "task received", hash)
    key = "option"+(hash.option)
    switch hash.action
      when "getOptions"
        result = if hash.mapping[key] then Crawler.getOptions(hash.mapping[key].paths) else []
      when "setOption"
        result = Crawler.setOption(hash.mapping[key].paths, hash.value)
      when "crawl"
        result = Crawler.crawl(hash.mapping)
      else
        logger.error("Unknow command", action)
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
    if location.host.search(/amazon.fr$/) isnt -1
      elem = document.getElementById('prime_feature_div')
      if elem && elem.style.opacity isnt ''
        setTimeout(waitAjax, 100)
      else
        goNextStep()
    else if ! Crawler.pageWillBeUnloaded
      setTimeout(goNextStep, satconf.DELAY_BETWEEN_OPTIONS)

  # To handle redirection, that throws false 'complete' state.
  $(document).ready () ->
    if crawlHelper && crawlHelper.at_load
      crawlHelper.at_load(goNextStep)
    else
      setTimeout(goNextStep, 100)
