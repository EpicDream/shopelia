class Shopelia.Controllers.Controller extends Backbone.Marionette.Controller

  getProduct:  ->
    Shopelia.Application.request("product")

  getSession:  ->
    Shopelia.Application.request("session")

  dispose: ->
    Shopelia.dispatcher.dispose(this)
