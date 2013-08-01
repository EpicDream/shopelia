class Shopelia.Controllers.Controller extends Backbone.Marionette.Controller

  getProduct:  ->
    Shopelia.Application.request("product")


  dispose: ->
    Shopelia.dispatcher.dispose(this)
