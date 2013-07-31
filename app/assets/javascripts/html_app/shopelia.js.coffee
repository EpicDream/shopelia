window.Shopelia =
  Controllers: {}
  Models: {}
  Views: {}
  Routers: {}
  Application: new Backbone.Marionette.Application()
  developerKey: $.cookie('developer_key') unless $.cookie('developer_key') is undefined
  SDKVersion: "0.1"
  SDK: "HTML"

Shopelia.Application.addInitializer (options) ->
  originalSync = Backbone.sync
  Backbone.sync = (method, model, options) ->
    #console.log("BACKBONE SYNC")
    options.headers = options.headers or {}
    options.contentType = 'application/json'
    _.extend(options.headers, {
                             "Accept": "application/json",
                             "Accept": "application/vnd.shopelia.v1",
                             "X-Shopelia-ApiKey": Shopelia.developerKey
                             })

    originalSync.call(this,method,model, options)
  new Shopelia.Routers.AppRouter()
  Backbone.history.start(pushState: true)


$(document).ready ->
  Shopelia.Application.start();
  Tracker.init()
  $.ajax({
         url: "/sdk/ads.js",
         dataType: "script",
         success: (data,textStatus,jqxhr) ->
            Shopelia.Adblock = false
         error: ->
            Shopelia.Adblock = true
         });







