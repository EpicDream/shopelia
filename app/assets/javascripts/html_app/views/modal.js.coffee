class Shopelia.Views.Modal extends Shopelia.Views.Layout

  template: 'modal'
  regions: {
    header: "#modal-header",
    content: "#modal-content"
    top: "#modal-top",
    left: "#modal-left",
    right: "#modal-right"
  }

  id: 'modal'
  className: 'span8'

  events:
    'click #close': 'close'

  initialize: ->
    messageListener = (e) ->
      window.shopeliaParentHost = e.origin
      window.removeEventListener("message",messageListener)
    DOMContentLoadedListener = () ->
      window.addEventListener("message",messageListener
      , false)
      window.parent.postMessage("loaded", "*")
      window.removeEventListener("DOMContentLoaded",DOMContentLoadedListener)
    window.addEventListener("DOMContentLoaded",DOMContentLoadedListener
    , false)
    that = this
    $(window).on('resize.modal',() ->
      that.center()
    )

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
    @center()

  close: ->
    #console.log("close please")
    $(@el).fadeOut({
                   duration: "fast",
                   complete: () ->
                    top.postMessage("deleteIframe",window.shopeliaParentHost)
                   })


  center: ->
    top = undefined
    left = undefined
    top = Math.max($(window).height() - $(@el).height(),0) / 2
    left = Math.max($(window).width() - $(@el).outerWidth(), 0) / 2

    $(@el).css
      top: top
      left: left
