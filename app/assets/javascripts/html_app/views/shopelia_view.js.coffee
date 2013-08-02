class Shopelia.Views.ShopeliaView extends Backbone.Marionette.ItemView

  initialize:  ->
    _.bindAll this

  getProduct:  ->
    console.log(Shopelia.Application.request("product"))
    Shopelia.Application.request("product")

  getSession:  ->
    console.log(Shopelia.Application.request("session"))
    Shopelia.Application.request("session")

