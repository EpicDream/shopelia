# Main for Saturn.
# Author : Vincent Renaudineau
# Created at : 2013-10-07

requirejs ['chrome_logger', 'src/chrome/saturn', 'src/chrome/adblock', 'satconf'],
(logger, ChromeSaturn, AdBlock) ->
  # Default to debug until Chrome propose tabs for each levels.
  logger.level = logger[satconf.log_level]

  saturn = new ChromeSaturn()
  window.saturn = saturn
  saturn.AdBlock = AdBlock
  AdBlock.saturn = saturn

  # On contentscript ask next step (next color/size tuple).
  chrome.extension.onMessage.addListener (msg, sender, response) ->
    return if sender.id != chrome.runtime.id || ! sender.tab || ! saturn.sessionsByTabId[sender.tab.id]
    if msg is "nextStep" && saturn.sessionsByTabId[sender.tab.id]
      saturn.sessionsByTabId[sender.tab.id].next()

  # On extension button clicked.
  chrome.browserAction.onClicked.addListener (tab) ->
    if satconf.run_mode is "auto"
      if saturn.crawl
        logger.info("Button pressed, Saturn is paused.")
        saturn.pause()
      else
        logger.info("Button pressed, Saturn is resumed.")
        saturn.resume()
    else
      logger.info("Button pressed, going to crawl current page...")
      saturn.parseCurrentPage(tab)

  chrome.tabs.onRemoved.addListener (tabId) ->
    saturn.closeTab(tabId)

  # Inter-extension messaging. Usefull for Ariane.
  chrome.extension.onConnectExternal.addListener (port) ->
    if port.sender.id isnt "aomdggmelcianmnecnijkolfnafpdbhm"
      return logger.warn('Extension', port.sender.id, "try to connect to us")
    saturn.externalPort = port
    port.onMessage.addListener (prod) ->
      if prod.tabId is undefined || prod.url is undefined
        return saturn.sendError(prod.id, 'some fields are missing.')
      prod.extensionId = port.sender.id
      prod.strategy ||= 'fast'
      prod.keepTabOpen = true
      saturn.onProductReceived(prod)

  chrome.management.onDisabled.addListener (extension) ->
    if extension.id is AdBlock.id
      AdBlock.enable()
  # Restart every 12h
  AdBlock.restartEvery(satconf.ADBLOCK_RESTART_DELAY)

  # Methods to restart Chrome periodically
  saturn.restartChrome = () ->
    if saturn.canRestart()
      logger.debug("Chrome : restart !")
      chrome.tabs.create({url: "chrome://restart/"})
    else 
      setTimeout( () ->
        saturn.restartChrome()
      , 1000*60*5); # Retry every 5 min
  saturn.lastChromeRestart = Date.now()
  if satconf.CHROME_RESTART_DELAY
    setTimeout (() -> saturn.restartChrome()), satconf.CHROME_RESTART_DELAY

  saturn.start() if satconf.run_mode is 'auto'
