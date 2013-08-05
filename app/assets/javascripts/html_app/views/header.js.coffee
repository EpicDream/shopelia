class Shopelia.Views.Header extends Shopelia.Views.ShopeliaView

  template: 'header'
  ui: {
    link: "#link-header"
  }

  setHeaderLink: (text,event,params) ->
    @ui.link.text(text)
    @ui.link.unbind("click")
    @ui.link.click ->
      Shopelia.vent.trigger(event,params)



