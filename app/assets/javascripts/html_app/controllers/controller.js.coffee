class Shopelia.Controllers.Controller extends Backbone.Marionette.Controller

  initialize: ->
    _.bindAll(this)

  getProduct:  ->
    Shopelia.Application.request("product")

  getSession:  ->
    Shopelia.Application.request("session")

  dispose: ->
    Shopelia.dispatcher.dispose(this)

  pushHeaderLink: (event,text,params) ->
    @_event = event
    Shopelia.vent.trigger("header#push_header_link",event,text,params)

  popHeaderLink: ->
    if @_event isnt undefined
      Shopelia.vent.trigger("header#pop_header_link")

  popAll: ->
    if @_event isnt undefined
      Shopelia.vent.trigger("header#pop_all",@_event)


  close: ->
    Backbone.Marionette.Controller.prototype.close.call(this)
    @dispose()
    @popAll()
    unless @view is undefined
      @view.close()

