class Shopelia.Views.Header extends Shopelia.Views.ShopeliaView

  template: 'header'
  ui: {
    link: "#link-header"
  }

  initialize: ->
    _.bindAll(this)
    Shopelia.vent.on( "hide:header_link", @hideHeaderLink)

  setHeaderLink: (text,event,params) ->
    @ui.link.text(text)
    @ui.link.unbind("click")
    @ui.link.click ->
      Shopelia.vent.trigger(event,params)

  hideHeaderLink: ->
    @ui.link.remove()

