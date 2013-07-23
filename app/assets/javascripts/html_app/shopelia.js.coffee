window.Shopelia =
  Models: {}
  Views: {}
  Routers: {}
  developerKey: $.cookie('developer_key')
  SDKVersion: "0.1"
  SDK: "HTML"

  initialize: ->
    originalSync = Backbone.sync
    Backbone.sync = (method, model, options) ->
      console.log("BACKBONE SYNC")
      options.headers = options.headers or {}
      options.contentType = 'application/json'
      _.extend(options.headers, {
                               "Accept": "application/json",
                               "Accept": "application/vnd.shopelia.v1",
                               "X-Shopelia-ApiKey": Shopelia.developerKey
                               })

      originalSync.call(this,method,model, options)
    new Shopelia.Routers.Sessions()
    Backbone.history.start(pushState: true)


$(document).ready ->
  Shopelia.initialize()
  Tracker.init()
  console.log($('#amIHere').length)
  if $('#amIHere').length isnt 0
    Shopelia.Adblock = false
  else
    Shopelia.Adblock = true






