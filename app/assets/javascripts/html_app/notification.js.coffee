class Shopelia.Notification

  constructor: (params) ->
    $.pnotify(params).click( (e) ->
              e.stopPropagation()
    )

  @Error : (params) ->
    params.type = "error"
    new Shopelia.Notification(params)

  @Success : (params) ->
    params.type = "success"
    new Shopelia.Notification(params)

  @Info : (params) ->
    params.type = "info"
    new Shopelia.Notification(params)
