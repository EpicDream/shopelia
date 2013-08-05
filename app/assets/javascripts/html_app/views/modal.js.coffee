class Shopelia.Views.Modal extends Shopelia.Views.Layout

  template: 'modal'
  regions: {
    header: "#modal-header",
    top: "#modal-top",
    left: "#modal-left",
    right: "#modal-right"
  }

  id: 'modal'
  className: 'span8'

  events:
    'click #close': 'close'

  initialize: ->
    #console.log(Shopelia.Views.ShopeliaView)
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)
    messageListener = (e) ->
      #console.log("set shopelia parent host")
      window.shopeliaParentHost = e.origin
      window.removeEventListener("message",messageListener)
    DOMContentLoadedListener = () ->
      window.addEventListener("message",messageListener
      , false)
      window.parent.postMessage("loaded", "*")
      window.removeEventListener("DOMContentLoaded",DOMContentLoadedListener)
    window.addEventListener("DOMContentLoaded",DOMContentLoadedListener
    , false)

  onRender: ->
    $(@el).fadeIn('slow')
    that = this
    $(@el).click (e) ->
      e.stopPropagation()

    $(document).click ->
      if $("#productInfosIframe").length > 0
        that.productView.closeProducIframe()
      else
        that.close()
    this

  close: ->
    #console.log("close please")
    $(@el).fadeOut({
                   duration: "fast",
                   complete: () ->
                    top.postMessage("deleteIframe",window.shopeliaParentHost)
                   })



