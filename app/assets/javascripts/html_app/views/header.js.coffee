class Shopelia.Views.Header extends Shopelia.Views.ShopeliaView

  template: 'header'
  ui: {
    link: "#link-header"
    info: "#info"
    phone: "#phone"
  }

  setHeaderLink: (headerLink) ->
    @ui.link.show()
    @ui.link.text(headerLink.text)
    @ui.link.unbind("click")
    @ui.link.click ->
      Shopelia.vent.trigger(headerLink.event,headerLink.params)

  hideHeaderLink: ->
    @ui.link.hide()

  hideAll: ->
    @ui.link.hide()
    @ui.info.hide()
    @ui.phone.hide()
    $("#modal-header").css "height", "30px"