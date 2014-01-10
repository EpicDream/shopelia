# ChromeLogger
# Author : Vincent RENAUDINEAU
# Created : 2013-11-06

requirejs ['jquery', 'chrome_logger', 'crawler', "satconf"],
($, logger, Crawler) ->

  logger.level = logger[satconf.log_level]
  Crawler.DELAY_BETWEEN_OPTIONS = satconf.DELAY_BETWEEN_OPTIONS

  class ChromeCrawler extends Crawler
    goNextStep: () ->
      if ! @pageWillBeUnloaded
        chrome.extension.sendMessage("nextStep")

  crawler = new ChromeCrawler()
  window.crawler = crawler
  helper = crawler.helper

  chrome.extension.onMessage.addListener (hash, sender, callback) =>
    return if sender.id isnt chrome.runtime.id
    result = crawler.doNext(hash)
    callback(result) if callback?
