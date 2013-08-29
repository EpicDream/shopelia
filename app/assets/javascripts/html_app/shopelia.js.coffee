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
  AbbaCartPosition: 'popup'

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
  if window.Shopelia.tracker == 'product-follow'
    window.Shopelia.AbbaCartPosition = 'none'
  else
    Abba("Product sign-up position").control("Popup").variant("Front top", ->
      window.Shopelia.AbbaCartPosition = 'top'
    ).variant("Front bottom", ->
      window.Shopelia.AbbaCartPosition = 'bottom'
    ).start()  
  $.pnotify.defaults.history = false
  Shopelia.Application.start()
  Tracker.init()
  #Abba("SPAM information").control("Show SPAM information").variant("Do not show SPAM information", ->
  #  window.Shopelia.AbbaShowSpam = false
  #).start()
