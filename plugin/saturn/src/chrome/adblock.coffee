# AdBlock facilities for Chrome
# Author : Vincent Renaudineau
# Created at : 2013-12-12

define 'src/chrome/adblock', ['chrome_logger', 'satconf'],
(logger) ->
  AdBlock = {
    id: "cfhdojbkjhnklbpkdaibdccddilifddb"
    lastRestart: Date.now()
    restart: (callback) ->
      @restartTimerId = undefined
      @onRestartCb = callback
      if this.canRestart()
        logger.debug("AdBlock : is restarting !")
        this.disable()
      else
        logger.debug("AdBlock : Saturn is busy, will try to restart later.")
        @restartTimerId = setTimeout (=> this.restart(callback)), 1000*60 # 1 min
    disable: () ->
      logger.debug("Disable AdBlock")
      @restarting = true
      chrome.management.setEnabled @id, false
    enable: () ->
      logger.debug("Enable AdBlock")
      chrome.management.setEnabled @id, true, (=> this.onRestart())
    onRestart: () ->
      logger.debug("AdBlock restarted !")
      @restarting = false
      @lastRestart = Date.now()
      if @restartEveryDelay
        this.restartIn(@restartEveryDelay)
      else if @nextRestartDate
        @nextRestartDate += 1000*3600*24
        this.restartIn(@nextRestartDate - Date.now())
      @onRestartCb() if @onRestartCb
    canRestart: () ->
      return @saturn.canRestart()
    restartIn: (ms) ->
      @restartTimerId = setTimeout( () =>
        this.restart()
      , ms)
    restartAt: (hour, min) ->
      now = new Date()
      @nextRestartDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, min || 0, 0, 0)
      if @nextRestartDate < now
        @nextRestartDate += 1000*3600*24
      this.restartIn(@nextRestartDate - now)
    restartEvery: (ms) ->
      return if (! ms)
      @restartEveryDelay = ms
      this.restartIn(@restartEveryDelay)
    cancelRestart: () ->
      clearTimeout(@restartTimerId)
  }

  chrome.management.onDisabled.addListener (extension) ->
    if extension.id is AdBlock.id && AdBlock.restarting
      setTimeout (-> AdBlock.enable()), 100

  return AdBlock
