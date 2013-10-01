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
  tracker: $.cookie('tracker') unless $.cookie('tracker') is undefined
  SDKVersion: "0.1"
  SDK: "HTML"
  AbbaShowSpam: true
  AbbaCartPosition: 'none'

Shopelia.Application.addRegions({
                 container: "#container"
                 })

Shopelia.Application.addInitializer (options) ->
  originalRender = Backbone.Marionette.Renderer.render
  Backbone.Marionette.Renderer.render = (template, data) ->
    if !JST[template]
      return originalRender.call(this,template, data)
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
  #if window.Shopelia.tracker == 'product-follow'
  #  window.Shopelia.AbbaCartPosition = 'none'
  #else if window.Shopelia.developerKey == 'e35c8cbbcfd7f83e4bb09eddb5a3f4c461c8d30a71dc498a9fdefe217e0fcd44'
  #  window.Shopelia.AbbaCartPosition = 'popup'
  #else
  #  Abba("Product sign-up position").control("Popup").variant("Front top", ->
  #    window.Shopelia.AbbaCartPosition = 'top'
  #  ).variant("Front bottom", ->
  #    window.Shopelia.AbbaCartPosition = 'bottom'
  #  ).start()  
  $.pnotify.defaults.history = false
  Shopelia.Application.start()
  Tracker.init()
  #Abba("SPAM information").control("Show SPAM information").variant("Do not show SPAM information", ->
  #  window.Shopelia.AbbaShowSpam = false
  #).start()
