
define ['logger', 'helper', 'core_extensions'], (logger, Helper) ->
  
  class PriceministerComHelper
    this.session =
      init: (session) ->
        session.oldUrl = session.url
        session.url = this.preProcessUrl(session.url)
        session.oldOpenUrl = session.openUrl
        session.openUrl = this.openUrl

      preProcessUrl: (url) ->
        if url.search(/filter=10/) isnt -1
          url
        else if url.search(/filter=\d0/) isnt -1
          url.replace(/filter=\d0/, 'filter=10')
        else
          url + if url.search(/#/) isnt -1 then "&filter=10" else "#filter=10"

      openUrl: () ->
        chrome.tabs.get @tabId, (tab) =>
          # if already open at the good url (with ariane)
          if tab.url is @url
            this.next()
          # already on priceminister, but with wrong url (with ariane)
          else if tab.url.search(/priceminister.com/) isnt -1
            chrome.tabs.update(@tabId, {url: @url}, (tab) =>
              chrome.tabs.update(@tabId, {url: @url})
            )
          # url not already open
          else
            chrome.tabs.update(@tabId, {url: @url})

  Helper.oldGet = Helper.get
  Helper.get = (url, context) ->
      if ! url || ! context
        null
      else if url.search(/^https?:\/\/www\.priceminister\.com/) isnt -1
        PriceministerComHelper[context]
      else
        Helper.oldGet(url, context)

  return Helper
