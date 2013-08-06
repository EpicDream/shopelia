class Shopelia.Views.Header extends Shopelia.Views.ShopeliaView

  template: 'header'
  ui: {
    link: "#link-header"
  }

  initialize: ->
    _.bindAll(this)

  setHeaderLink: (headerLink) ->
    @ui.link.text(headerLink.text)
    @ui.link.unbind("click")
    @ui.link.click ->
      Shopelia.vent.trigger(headerLink.event,headerLink.params)

  hideHeaderLink: ->
    @ui.link.remove()

