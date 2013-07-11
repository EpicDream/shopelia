window.Shopelia =
  Models: {}
  Views: {}
  Routers: {}
  initialize: ->
    originalSync = Backbone.sync
    Backbone.sync = (method, model, options) ->
      console.log("BACKBONE SYNC")
      console.log(method)
      options.headers = options.headers or {}
      options.contentType = 'application/json'
      _.extend(options.headers, {
                               "Accept": "application/json",
                               "Accept": "application/vnd.shopelia.v1",
                               "X-Shopelia-ApiKey":"52953f1868a7545011d979a8c1d0acbc310dcb5a262981bd1a75c1c6f071ffb4"
                               })

      originalSync.call(this,method,model, options)
    new Shopelia.Routers.Sessions()
    Backbone.history.start(pushState: true)



$(document).ready ->
  Shopelia.initialize()
  Tracker.init()
