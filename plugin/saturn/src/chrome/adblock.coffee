# AdBlock facilities for Chrome
# Author : Vincent Renaudineau
# Created at : 2013-12-12

define 'src/chrome/adblock', ['chrome_logger', 'satconf'],
(logger) ->
  return {
    id: "cfhdojbkjhnklbpkdaibdccddilifddb"
    lastRestart: Date.now()
    restart: (callback) ->
      logger.debug("AdBlock : restart !")
      this.onRestartCb = callback
      if this.canRestart()
        this.saturn.pause()
        this.disable()
      else
        setInterval( () =>
          this.restart()
        , 1000*60*5)
    disable: () ->
      logger.debug("Disable AdBlock")
      chrome.management.setEnabled(this.id, false)
    enable: () ->
      logger.debug("Enable AdBlock")
      chrome.management.setEnabled(this.id, true, =>
        this.onRestart()
      )
    onRestart: () ->
      logger.debug("AdBlock restarted !")
      this.saturn.resume()
      this.lastRestart = Date.now()
      if this.restartEveryDelay
        this.restartIn(this.restartEveryDelay)
      else if this.nextRestartDate
        this.nextRestartDate += 1000*3600*24
        this.restartIn(this.nextRestartDate - Date.now())
      this.onRestartCb() if this.onRestartCb
    canRestart: () ->
      return this.saturn.canRestart()
    restartIn: (ms) ->
      setTimeout( () =>
        this.restart()
      , ms)
    restartAt: (hour, min) ->
      now = new Date()
      this.nextRestartDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, min || 0, 0, 0)
      if this.nextRestartDate < now
        this.nextRestartDate += 1000*3600*24
      this.restartIn(this.nextRestartDate - now)
    restartEvery: (ms) ->
      return if (! ms)
      this.restartEveryDelay = ms
      this.restartIn(this.restartEveryDelay)
  }
