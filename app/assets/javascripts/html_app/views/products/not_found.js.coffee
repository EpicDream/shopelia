class Shopelia.Views.NotFound extends Shopelia.Views.ShopeliaView

  template: 'products/not_found'
  templateHelpers: {
    model: (attr) ->
      console.log(@)
      @product[attr]
  }

  onRender: ->
    Tracker.onDisplay('Product Not Found');