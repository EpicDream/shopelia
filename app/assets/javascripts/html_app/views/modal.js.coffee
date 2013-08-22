class Shopelia.Views.Modal extends Shopelia.Views.Layout

  template: 'modal'
  regions: {
    header: "#modal-header",
    content: "#modal-content"
    top: "#modal-top",
  }

  ui:{
    close:"#close"
  }

  id: 'modal'
  className: 'span8'

  events:
    'click #close': 'onBeforeClose'

  initialize: ->
    _.bindAll(this)
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
    $(window).on('load',() ->
      that.center()
      $(that.el).fadeIn('slow')
    )


  onRender: ->
    that = this
    $(@el).click (e) ->
      e.stopPropagation()

    $(document).click ->
        that.onBeforeClose()

  showCloseButton: ->
    @ui.close.fadeIn("fast")

  hideCloseButton: ->
    @ui.close.fadeOut("fast")

  onBeforeClose: ->
    that = this
    Shopelia.vent.trigger("description#close")
    Shopelia.vent.trigger("modal_content#show_add_to_cart")
    $(document).unbind('click')
    @ui.close.unbind('click')
    @ui.close.click ->
      that.close()
    $(document).click ->
      that.close()

  close: ->
    #console.log("close please")
    $(@el).fadeOut({
                   duration: "fast",
                   complete: () ->
                    top.postMessage("deleteIframe",window.shopeliaParentHost)
                   })


  center: (animate) ->
    top = undefined
    left = undefined
    top = Math.max($(window).height() - $(@el).height(),0) / 2
    left = Math.max($(window).width() - $(@el).outerWidth(), 0) / 2

    if animate
      $(@el).animate({
                     top: top
                     left: left
                           },500,"easeOutQuint")

    $(@el).css
      top: top
      left: left
