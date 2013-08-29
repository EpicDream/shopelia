class Shopelia.Notification

  constructor: (params) ->
    _.extend(params,{
            icon:  false
            sticker: false
            closer_hover : false
    })

    if params.center
      params = @center(params)
    $.pnotify(params).click( (e) ->
              e.stopPropagation()
    )

  @Error : (params) ->
    params.type = "error"
    if params.title is undefined
      params.title = "Erreur"
    new Shopelia.Notification(params)

  @Success : (params) ->
    params.type = "success"
    if params.title is undefined
      params.title = "Succ?s"
    new Shopelia.Notification(params)

  @Info : (params) ->
    params.type = "info"
    if params.title is undefined
      params.title = "Information"
    new Shopelia.Notification(params)

  @Notice : (params) ->
    params.type = "notice"
    if params.title is undefined
      params.title = "Notification"
    new Shopelia.Notification(params)

  center: (params)  ->
    if (typeof center_box != "undefined")
        center_box.pnotify_display()
        return
    that = this
    _.extend(params,{
             delay: 20000,
             history: false,
             stack: false,
             before_open: (pnotify) ->
               pnotify.css({
                           "top": ($(window).height() / 2) - (pnotify.height() / 2),
                           "left": ($(window).width() / 2) - (pnotify.width() / 2)
                           })
               if (that.modal_overlay)
                 that.modal_overlay.fadeIn("fast")
               else
                 that.modal_overlay = $("<div />", {
                 "class": "ui-widget-overlay",
                 "css": {
                 "display": "none",
                 "position": "fixed",
                 "top": "0",
                 "bottom": "0",
                 "right": "0",
                 "left": "0"
                 }
                 })
                   .appendTo("body").fadeIn("fast")
               that.modal_overlay.click((e) ->
                e.stopPropagation()
                )
             before_close: () ->
               that.modal_overlay.fadeOut("fast")

             })
    return params