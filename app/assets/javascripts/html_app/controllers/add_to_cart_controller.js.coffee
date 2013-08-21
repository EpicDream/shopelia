class Shopelia.Controllers.AddToCartController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this

  show:(region) ->
    @view = new Shopelia.Views.AddToCart()
    region.show(@view)


