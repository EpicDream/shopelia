window.Shopelia =
  Controllers: {}
  Collections: {}
  Models: {}
  Views: {}
  Routers: {}
  Dispatchers: {}
  Application: new Backbone.Marionette.Application()
  vent: new Backbone.Wreqr.EventAggregator()
  developerKey: $.cookie('developer_key') unless $.cookie('developer_key') is undefined
  SDKVersion: "0.1"
  SDK: "HTML"

Shopelia.Application.addRegions({
                 container: "#container"
                 })

Shopelia.Application.addInitializer (options) ->
  Backbone.Marionette.Renderer.render = (template, data) ->
    if !JST[template]
      throw "Template '" + template + "' not found!"
    JST[template](data)

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
  ###### Creating Custom Dipatcher#####
  Shopelia.dispatcher =  new Shopelia.Dispatchers.Dispatcher(Shopelia.vent)
  ###### Start Router #####
  new Shopelia.Routers.AppRouter()
  Backbone.history.start(pushState: true)




$(document).ready ->
  Shopelia.Application.start()
  Tracker.init()
  $.ajax({
         url: "/sdk/ads.js",
         dataType: "script",
         success: (data,textStatus,jqxhr) ->
            Shopelia.Adblock = false
         error: ->
            Shopelia.Adblock = true
         });







