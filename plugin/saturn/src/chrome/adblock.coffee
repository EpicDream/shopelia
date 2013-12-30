# AdBlock facilities for Chrome
# Author : Vincent Renaudineau
# Created at : 2013-12-12

define 'src/chrome/adblock', ['chrome_logger', 'satconf'],
(logger) ->
  AdBlock = {
    id: "cfhdojbkjhnklbpkdaibdccddilifddb"
    lastRestart: Date.now()
    restart: (callback) ->
      logger.debug("AdBlock : restart !")
      @onRestartCb = callback
      if this.canRestart()
        @saturn.pause()
        this.disable()
      else
        setInterval (=> this.restart(callback)), 1000*60*5 # 5 min
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
      @saturn.resume()
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
      setTimeout( () =>
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
  }

  chrome.management.onDisabled.addListener (extension) ->
    if extension.id is AdBlock.id && AdBlock.restarting
      AdBlock.enable()

  return AdBlock
